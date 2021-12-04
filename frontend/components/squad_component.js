import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"
import { t }       from "ttag"

import { localizeValue, localizeRoute } from "./utils/localize"
import { showAlerts } from "./utils/alerts"
import { sportsData } from "./utils/sports"

Vue.use(VueResource)
Vue.http.interceptors.push(function(request) {
  request.headers.set("X-CSRF-TOKEN", document.querySelector("meta[name='csrf-token']").getAttribute("content"))
})

const squadViewSelector = "#fantasy-team-squad"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(squadViewSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const sportKind = element.dataset.sportKind
  const lineupId = element.dataset.lineupId

  const squadComponent = new Vue({
    el: squadViewSelector,
    data: {
      teamsById: {},
      sportsPositions: [],
      sportsPositionsByKind: {},
      players: [],
      changePlayerId: null,
      changeOptionIds: []
    },
    created() {
      this.getTeams()
      this.getSportsPositions()
      this.getLineupPlayers()
    },
    computed: {
    },
    methods: {
      localizeValue: function(value) {
        return localizeValue(value)
      },
      getTeams: function() {
        this.$http.get(localizeRoute(`/teams.json?season_id=${seasonId}`)).then(function(data) {
          data.body.teams.data.forEach((element) => {
            this.teamsById[element.id] = element.attributes.name
          })
        })
      },
      getSportsPositions: function() {
        Object.entries(sportsData.positions).forEach(([positionKind, element]) => {
          if (element.sport_kind !== sportKind) return

          element.position_kind = positionKind
          this.sportsPositions.push(element)
          this.sportsPositionsByKind[positionKind] = { name: element.name, totalAmount: element.total_amount }
          return element.attributes
        })
      },
      getLineupPlayers: function() {
        this.$http.get(localizeRoute(`/lineups/${lineupId}/players.json?fields=opposite_teams`)).then(function(data) {
          this.players = data.body.lineup_players.data.map((element) => element.attributes)
        })
      },
      teamNameById: function(teamId) {
        return this.teamsById[teamId]
      },
      activePlayersForPosition: function(sportPositionKind) {
        return this.players.filter((element) => {
          return element.active && element.player.position_kind === sportPositionKind
        })
      },
      reservePlayers: function() {
        return this.players.filter((element) => {
          return !element.active
        }).sort((a, b) => {
          return a.change_order > b.change_order
        })
      },
      activePlayers: function() {
        return this.players.filter((element) => {
          return element.active
        })
      },
      oppositeTeamNames: function(teamMember) {
        const values = teamMember.team.opposite_team_ids
        if (values.length === 0) return "-"

        return values.map((element) => localizeValue(this.teamNameById(element))).join(", ")
      },
      changeActivePlayer: function(teamMember) {
        // beginning of change selection
        if (this.changePlayerId === null) {
          const positionKind = teamMember.player.position_kind
          this.reservePlayers().forEach((element) => {
            const nextPositionKind = element.player.position_kind
            // allow change for the same position
            if (nextPositionKind === positionKind) {
              this.changeOptionIds.push(element.id)
              return
            }
            // skip change if current position player amount will left less than minimum
            const activePlayersOnCurrentPosition = this.activePlayersForPosition(positionKind).length
            if (activePlayersOnCurrentPosition === this.sportsPositionsById[positionKind].min_game_amount) return
            // and if change position player amount will be more than maximum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionKind).length
            if (activePlayersOnNextPosition === this.sportsPositionsById[nextPositionKind].max_game_amount) return
            this.changeOptionIds.push(element.id)
          })
          if (this.changeOptionIds.length > 0) this.changePlayerId = teamMember.id
        } else {
          if (!this.changeOptionIds.includes(teamMember.id)) return
          this.changePlayers(teamMember.id, false)
        }
      },
      changeReservePlayer: function(teamMember) {
        if (this.changePlayerId === null) {
          const positionKind = teamMember.player.position_kind
          this.activePlayers().forEach((element) => {
            const nextPositionKind = element.player.position_kind
            // allow change for the same position
            if (nextPositionKind === positionKind) {
              this.changeOptionIds.push(element.id)
              return
            }
            // skip change if current position player amount will left more than maximum
            const activePlayersOnCurrentPosition = this.activePlayersForPosition(positionKind).length
            if (activePlayersOnCurrentPosition === this.sportsPositionsById[positionKind].max_game_amount) return
            // and if change position player amount will be less than minimum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionKind).length
            if (activePlayersOnNextPosition === this.sportsPositionsById[nextPositionKind].min_game_amount) return
            this.changeOptionIds.push(element.id)
          })
          if (this.changeOptionIds.length > 0) this.changePlayerId = teamMember.id
        } else {
          if (!this.changeOptionIds.includes(teamMember.id)) return
          this.changePlayers(teamMember.id, true)
        }
      },
      changePlayers: function(changeableId, stateForInitialPlayer) {
        // this.changePlayerId - id of initial player
        // stateForInitialPlayer - new state for initial player
        // changeableId - id of changeable player
        const changePlayerInArray = this.players.find((element) => {
          return element.id === this.changePlayerId
        })
        if (changePlayerInArray === undefined) return
        const changeablePlayerInArray = this.players.find((element) => {
          return element.id === changeableId
        })
        if (changeablePlayerInArray === undefined) return

        const changePlayerIndex = this.players.indexOf(changePlayerInArray)
        const changeablePlayerIndex = this.players.indexOf(changeablePlayerInArray)

        const changeOrder = Math.max(changePlayerInArray.change_order, changeablePlayerInArray.change_order)
        changePlayerInArray.active = !stateForInitialPlayer
        changePlayerInArray.change_order = stateForInitialPlayer ? changeOrder : 0
        changeablePlayerInArray.active = stateForInitialPlayer
        changeablePlayerInArray.change_order = stateForInitialPlayer ? 0 : changeOrder
        this.changePlayerId = null
        this.changeOptionIds = []

        Vue.set(this.players, changePlayerIndex, changePlayerInArray)
        Vue.set(this.players, changeablePlayerIndex, changeablePlayerInArray)
      },
      submit: function() {
        const payload = {
          data: this.players.map((element) => {
            return {
              id:           element.id,
              active:       element.active,
              change_order: element.change_order
            }
          })
        }
        this.$http.patch(localizeRoute(`/lineups/${lineupId}/players.json`), { lineup_players: payload }).then(function(data) {
          showAlerts("notice", `<p>${t`Lineup is saved`}</p>`)
        })
      }
    }
  })
})

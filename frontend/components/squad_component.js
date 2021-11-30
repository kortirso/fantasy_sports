import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"

import { localizeValue } from "./utils/localize"

Vue.use(VueResource)
Vue.http.interceptors.push(function(request) {
  request.headers.set("X-CSRF-TOKEN", document.querySelector("meta[name='csrf-token']").getAttribute("content"))
})

const transfersViewSelector = "#fantasy-team-squad"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(transfersViewSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const lineupId = element.dataset.lineupId

  const transfersComponent = new Vue({
    el: transfersViewSelector,
    data: {
      teamsById: {},
      sportsPositions: [],
      sportsPositionsById: {},
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
        this.$http.get(`/teams.json?season_id=${seasonId}`).then(function(data) {
          data.body.teams.data.forEach((element) => {
            this.teamsById[element.id] = element.attributes.name
          })
        })
      },
      getSportsPositions: function() {
        this.$http.get(`/sports/positions.json?season_id=${seasonId}&fields=min_game_amount,max_game_amount`).then(function(data) {
          this.sportsPositions = data.body.sports_positions.data.map((element) => {
            this.sportsPositionsById[element.id] = {
              name:          element.attributes.name,
              minGameAmount: element.attributes.min_game_amount,
              maxGameAmount: element.attributes.max_game_amount
            }
            return element.attributes
          })
        })
      },
      getLineupPlayers: function() {
        this.$http.get(`/fantasy_teams/lineups/${lineupId}/players.json`).then(function(data) {
          this.players = data.body.lineup_players.data.map((element) => element.attributes)
        })
      },
      teamNameById: function(teamId) {
        return this.teamsById[teamId]
      },
      activePlayersForPosition: function(sportPositionId) {
        return this.players.filter((element) => {
          return element.active && element.player.sports_position_id === sportPositionId
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
      changeActivePlayer: function(teamMember) {
        // beginning of change selection
        if (this.changePlayerId === null) {
          const positionId = teamMember.player.sports_position_id
          this.reservePlayers().forEach((element) => {
            const nextPositionId = element.player.sports_position_id
            // allow change for the same position
            if (nextPositionId === positionId) {
              this.changeOptionIds.push(element.id)
              return
            }
            // skip change if current position player amount will left less than minimum
            const activePlayersOnCurrentPosition = this.activePlayersForPosition(positionId).length
            if (activePlayersOnCurrentPosition === this.sportsPositionsById[positionId].minGameAmount) return
            // and if change position player amount will be more than maximum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionId).length
            if (activePlayersOnNextPosition === this.sportsPositionsById[nextPositionId].maxGameAmount) return
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
          const positionId = teamMember.player.sports_position_id
          this.activePlayers().forEach((element) => {
            const nextPositionId = element.player.sports_position_id
            // allow change for the same position
            if (nextPositionId === positionId) {
              this.changeOptionIds.push(element.id)
              return
            }
            // skip change if current position player amount will left more than maximum
            const activePlayersOnCurrentPosition = this.activePlayersForPosition(positionId).length
            if (activePlayersOnCurrentPosition === this.sportsPositionsById[positionId].maxGameAmount) return
            // and if change position player amount will be less than minimum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionId).length
            if (activePlayersOnNextPosition === this.sportsPositionsById[nextPositionId].minGameAmount) return
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
        this.$http.patch(`/fantasy_teams/lineups/${lineupId}/players.json`, { lineup_players: payload }).then(function(data) {
        })
      }
    }
  })
})

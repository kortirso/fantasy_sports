import * as Vue from "vue"

import { localizeValue, localizeRoute } from "utils/localize"
import { showAlerts } from "utils/alerts"
import { sportsData } from "utils/sports"

const squadViewSelector = "#fantasy-team-squad"

const element = document.querySelector(squadViewSelector)
if (element !== null) {
  const seasonId = element.dataset.seasonId
  const sportKind = element.dataset.sportKind
  const lineupId = element.dataset.lineupId

  Vue.createApp({
    data() {
      return {
        teamsById: {},
        sportsPositions: [],
        sportsPositionsByKind: {},
        players: [],
        changePlayerId: null,
        changeOptionIds: []
      }
    },
    created() {
      this.getTeams()
      this.getSportsPositions()
      this.getLineupPlayers()
    },
    methods: {
      localizeValue(value) {
        return localizeValue(value)
      },
      getTeams() {
        const _this = this
        fetch(localizeRoute(`/teams.json?season_id=${seasonId}`))
          .then(response => response.json())
          .then(function(data) {
            data.teams.data.forEach((element) => {
              _this.teamsById[element.id] = element.attributes.name
            })
          })
      },
      getSportsPositions() {
        Object.entries(sportsData.positions).forEach(([positionKind, element]) => {
          if (element.sport_kind !== sportKind) return

          element.position_kind = positionKind
          this.sportsPositions.push(element)
          this.sportsPositionsByKind[positionKind] = element
          return element.attributes
        })
      },
      getLineupPlayers() {
        const _this = this
        fetch(localizeRoute(`/lineups/${lineupId}/players.json?fields=opposite_teams`))
          .then(response => response.json())
          .then(function(data) {
            _this.players = data.lineup_players.data.map((element) => element.attributes)
          })
      },
      teamNameById(teamId) {
        return this.teamsById[teamId]
      },
      activePlayersForPosition(sportPositionKind) {
        return this.players.filter((element) => {
          return element.active && element.player.position_kind === sportPositionKind
        })
      },
      reservePlayers() {
        return this.players.filter((element) => {
          return !element.active
        }).sort((a, b) => {
          return a.change_order > b.change_order
        })
      },
      activePlayers() {
        return this.players.filter((element) => {
          return element.active
        })
      },
      oppositeTeamNames(teamMember) {
        const values = teamMember.team.opposite_team_ids
        if (values.length === 0) return "-"

        return values.map((element) => localizeValue(this.teamNameById(element))).join(", ")
      },
      changeActivePlayer(teamMember) {
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
            if (activePlayersOnCurrentPosition === this.sportsPositionsByKind[positionKind].min_game_amount) return
            // and if change position player amount will be more than maximum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionKind).length
            if (activePlayersOnNextPosition === this.sportsPositionsByKind[nextPositionKind].max_game_amount) return
            this.changeOptionIds.push(element.id)
          })
          if (this.changeOptionIds.length > 0) this.changePlayerId = teamMember.id
        } else {
          if (!this.changeOptionIds.includes(teamMember.id)) return
          this.changePlayers(teamMember.id, false)
        }
      },
      changeReservePlayer(teamMember) {
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
            if (activePlayersOnCurrentPosition === this.sportsPositionsByKind[positionKind].max_game_amount) return
            // and if change position player amount will be less than minimum
            const activePlayersOnNextPosition = this.activePlayersForPosition(nextPositionKind).length
            if (activePlayersOnNextPosition === this.sportsPositionsByKind[nextPositionKind].min_game_amount) return
            this.changeOptionIds.push(element.id)
          })
          if (this.changeOptionIds.length > 0) this.changePlayerId = teamMember.id
        } else {
          if (!this.changeOptionIds.includes(teamMember.id)) return
          this.changePlayers(teamMember.id, true)
        }
      },
      changePlayers(changeableId, stateForInitialPlayer) {
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

        //Vue.set(this.players, changePlayerIndex, changePlayerInArray)
        //Vue.set(this.players, changeablePlayerIndex, changeablePlayerInArray)
      },
      submit() {
        const payload = {
          data: this.players.map((element) => {
            return {
              id:           element.id,
              active:       element.active,
              change_order: element.change_order
            }
          })
        }
        fetch(
          localizeRoute(`/lineups/${lineupId}/players.json`),
          {
            method:  "PATCH",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").getAttribute("content")
            },
            body:    JSON.stringify({ lineup_players: payload })
          }
        )
          .then(response => response.json())
          .then(function(data) {
            if (data.message) {
              showAlerts("notice", `<p>${data.message}</p>`)
            } else {
              data.errors.forEach((error) => showAlerts("alert", `<p>${error}</p>`))
            }
          })
      }
    }
  }).mount(squadViewSelector)
}

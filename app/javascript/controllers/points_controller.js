import * as Vue from "vue"

import { localizeValue, localizeRoute } from "utils/localize"
import { showAlerts } from "utils/alerts"
import { sportsData } from "utils/sports"

const squadPointsSelector = "#fantasy-team-points"

const element = document.querySelector(squadPointsSelector)
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
        players: []
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
          this.sportsPositionsByKind[positionKind] = { name: element.name, totalAmount: element.total_amount }
          return element.attributes
        })
      },
      getLineupPlayers() {
        const _this = this
        fetch(localizeRoute(`/lineups/${lineupId}/players.json`))
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
      }
    }
  }).mount(squadPointsSelector)
}

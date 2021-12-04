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

const squadPointsSelector = "#fantasy-team-points"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(squadPointsSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const sportKind = element.dataset.sportKind
  const lineupId = element.dataset.lineupId

  const squadComponent = new Vue({
    el: squadPointsSelector,
    data: {
      teamsById: {},
      sportsPositions: [],
      sportsPositionsByKind: {},
      players: []
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
        this.$http.get(localizeRoute(`/lineups/${lineupId}/players.json`)).then(function(data) {
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
      }
    }
  })
})

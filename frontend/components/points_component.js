import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"
import { t }       from "ttag"

import { localizeValue, localizeRoute } from "./utils/localize"
import { showAlerts } from "./utils/alerts"

Vue.use(VueResource)
Vue.http.interceptors.push(function(request) {
  request.headers.set("X-CSRF-TOKEN", document.querySelector("meta[name='csrf-token']").getAttribute("content"))
})

const squadPointsSelector = "#fantasy-team-points"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(squadPointsSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const sportId = element.dataset.sportId
  const lineupId = element.dataset.lineupId

  const squadComponent = new Vue({
    el: squadPointsSelector,
    data: {
      teamsById: {},
      sportsPositions: [],
      sportsPositionsById: {},
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
        this.$http.get(localizeRoute(`/sports/${sportId}/positions.json?fields=min_game_amount,max_game_amount`)).then(function(data) {
          this.sportsPositions = data.body.sports_positions.data.map((element) => {
            this.sportsPositionsById[element.id] = element.attributes
            return element.attributes
          })
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
      }
    }
  })
})

import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"

Vue.use(VueResource)

const elementSelector = "#fantasy-team-picker"

document.addEventListener("DOMContentLoaded", () => {
  if (document.querySelector(elementSelector) === null) return

  const team = new Vue({
    el: "#fantasy-team-picker",
    data: {
      teams: [],
      teamsById: {},
      sportsPositions: [],
      sportsPositionsById: {},
      teamsPlayers: [],
      teamMembers: [],
      budget: 100
    },
    created() {
      this.getTeams()
      this.getSportsPositions()
      this.getTeamsPlayers()
    },
    computed: {
    },
    methods: {
      getTeams: function() {
        this.$http.get("/teams", { params: { league_id: 1 } }).then(function(data) {
          this.teams = data.body.teams.data.map((element) => {
            this.teamsById[element.id] = element.attributes.name
            return element.attributes
          })
        })
      },
      getSportsPositions: function() {
        this.$http.get("/sports/positions", { params: { league_id: 1 } }).then(function(data) {
          this.sportsPositions = data.body.sports_positions.data.map((element) => {
            this.sportsPositionsById[element.id] = element.attributes.name
            return element.attributes
          })
        })
      },
      getTeamsPlayers: function() {
        this.$http.get("/teams/players", { params: { league_id: 1 } }).then(function(data) {
          this.teamsPlayers = data.body.teams_players.data.map((element) => element.attributes)
        })
      },
      teamNameById: function(teamId) {
        if (this.teams.length === 0) return ''

        return this.teamsById[teamId]
      },
      sportPositionNameById: function(sportPositionId) {
        if (this.sportsPositions.length === 0) return ''

        return this.sportsPositionsById[sportPositionId]
      },
      addTeamMember: function(teamPlayer) {
        if (this.playerInTheTeam(teamPlayer)) return

        this.teamMembers.push(teamPlayer)
        this.budget = 100 - this.teamMembers.reduce((acc, element) => acc + element.price, 0)
      },
      teamMembersForPosition: function(sportPositionId) {
        return this.teamMembers.filter((element) => {
          return element.player.sports_position_id === sportPositionId
        })
      },
      playerInTheTeam: function(teamPlayer) {
        return this.teamMembers.includes(teamPlayer)
      }
    }
  })
})

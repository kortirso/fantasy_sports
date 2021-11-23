import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"

Vue.use(VueResource)
Vue.http.interceptors.push(function(request) {
  request.headers.set("X-CSRF-TOKEN", document.querySelector("meta[name='csrf-token']").getAttribute("content"))
})

const elementSelector = "#fantasy-team-picker"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(elementSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const fantasyTeamUuid = element.dataset.fantasyTeamUuid

  const team = new Vue({
    el: elementSelector,
    data: {
      teamName: "My team",
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
        this.$http.get(`/teams?season_id=${seasonId}`).then(function(data) {
          data.body.teams.data.forEach((element) => {
            this.teamsById[element.id] = element.attributes.name
          })
        })
      },
      getSportsPositions: function() {
        this.$http.get(`/sports/positions?season_id=${seasonId}`).then(function(data) {
          this.sportsPositions = data.body.sports_positions.data.map((element) => {
            this.sportsPositionsById[element.id] = { name: element.attributes.name, totalAmount: element.attributes.total_amount }
            return element.attributes
          })
        })
      },
      getTeamsPlayers: function() {
        this.$http.get(`/teams/players?season_id=${seasonId}`).then(function(data) {
          this.teamsPlayers = data.body.teams_players.data.map((element) => element.attributes)
        })
      },
      teamNameById: function(teamId) {
        return this.teamsById[teamId]
      },
      sportPositionById: function(sportPositionId) {
        return this.sportsPositionsById[sportPositionId]
      },
      addTeamMember: function(teamPlayer) {
        // if player is already in team
        if (this.playerInTheTeam(teamPlayer)) return
        // if all position already in use
        const sportPositionId = teamPlayer.player.sports_position_id
        const positionsLeft = this.sportPositionById(sportPositionId).totalAmount - this.teamMembersForPosition(sportPositionId).length
        if (positionsLeft === 0) return
        // if there are already 3 players from one team
        const playersFromTeam = this.teamMembers.filter((element) => {
          return element.team.id === teamPlayer.team.id
        })
        if (playersFromTeam.length === 3) return

        this.teamMembers.push(teamPlayer)
        this.updateBudget()
      },
      removeTeamMember: function(teamPlayer) {
        const teamMembers = this.teamMembers
        const playerIndex = teamMembers.indexOf(teamPlayer)
        if (playerIndex === -1) return

        teamMembers.splice(playerIndex, 1)
        this.teamMembers = teamMembers
        this.updateBudget()
      },
      updateBudget: function() {
        this.budget = 100 - this.teamMembers.reduce((acc, element) => acc + element.price, 0)
      },
      teamMembersForPosition: function(sportPositionId) {
        return this.teamMembers.filter((element) => {
          return element.player.sports_position_id === sportPositionId
        })
      },
      playerInTheTeam: function(teamPlayer) {
        return this.teamMembers.includes(teamPlayer)
      },
      submit: function() {
        const payload = {
          fantasy_team: {
            name: this.teamName,
            teams_players_ids: this.teamMembers.map((element) => element.id)
          }
        }
        this.$http.patch(`/fantasy_teams/${fantasyTeamUuid}.json`, payload).then(function(data) {
          window.location = data.body.redirect_path
        })
      }
    }
  })
})

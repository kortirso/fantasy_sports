import Vue         from "vue/dist/vue.esm"
import VueResource from "vue-resource"

import { localizeValue, localizeRoute } from "./utils/localize"
import { sportsData } from "./utils/sports"

Vue.use(VueResource)
Vue.http.interceptors.push(function(request) {
  request.headers.set("X-CSRF-TOKEN", document.querySelector("meta[name='csrf-token']").getAttribute("content"))
})

const transfersViewSelector = "#fantasy-team-transfers"

document.addEventListener("DOMContentLoaded", () => {
  const element = document.querySelector(transfersViewSelector)
  if (element === null) return

  const seasonId = element.dataset.seasonId
  const sportKind = element.dataset.sportKind
  const fantasyTeamUuid = element.dataset.fantasyTeamUuid

  const transfersComponent = new Vue({
    el: transfersViewSelector,
    data: {
      teamName: "My team",
      teamsById: {},
      sportsPositions: [],
      sportsPositionsByKind: {},
      teamsPlayers: [],
      teamMembers: [],
      existedTeamMembers: [],
      budget: parseFloat(element.dataset.fantasyTeamBudget),
      completed: element.dataset.fantasyTeamCompleted === 'true'
    },
    created() {
      this.getTeams()
      this.getSportsPositions()
      this.getTeamsPlayers()

      if (this.completed) this.getFantasyTeamPlayers()
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
      getTeamsPlayers: function() {
        this.$http.get(localizeRoute(`/seasons/${seasonId}/players.json?fields=season_statistic`)).then(function(data) {
          this.teamsPlayers = data.body.season_players.data.map((element) => element.attributes)
        })
      },
      getFantasyTeamPlayers: function() {
        this.$http.get(localizeRoute(`/fantasy_teams/${fantasyTeamUuid}/players.json`)).then(function(data) {
          this.teamMembers = data.body.teams_players.data.map((element) => element.attributes)
        })
      },
      teamNameById: function(teamId) {
        return this.teamsById[teamId]
      },
      sportPositionByKind: function(sportPositionKind) {
        return this.sportsPositionsByKind[sportPositionKind]
      },
      addTeamMember: function(teamPlayer) {
        // if player is already in team
        if (this.playerInTheTeam(teamPlayer)) return
        // if all position already in use
        const sportPositionKind = teamPlayer.player.position_kind
        const positionsLeft = this.sportPositionByKind(sportPositionKind).totalAmount - this.teamMembersForPosition(sportPositionKind).length
        if (positionsLeft === 0) return
        // if there are already 3 players from one team
        const playersFromTeam = this.teamMembers.filter((element) => {
          return element.team.id === teamPlayer.team.id
        })
        if (playersFromTeam.length === 3) return

        this.teamMembers.push(teamPlayer)
        this.updateBudget(- teamPlayer.price)
      },
      removeTeamMember: function(teamPlayer) {
        const teamMembers = this.teamMembers
        const teamPlayerInArray = this.teamMembers.find((element) => {
          return element.id === teamPlayer.id
        })
        if (teamPlayerInArray === undefined) return

        const playerIndex = teamMembers.indexOf(teamPlayerInArray)
        if (playerIndex === -1) return

        teamMembers.splice(playerIndex, 1)
        this.teamMembers = teamMembers
        this.updateBudget(teamPlayer.price)
      },
      resetTransfers: function() {
        this.getFantasyTeamPlayers()
        this.budget = parseFloat(element.dataset.fantasyTeamBudget)
      },
      updateBudget: function(value) {
        this.budget += value
      },
      teamMembersForPosition: function(sportPositionKind) {
        return this.teamMembers.filter((element) => {
          return element.player.position_kind === sportPositionKind
        })
      },
      playerInTheTeam: function(teamPlayer) {
        return this.teamMembers.includes(teamPlayer)
      },
      submit: function() {
        if (this.completed) return

        const payload = {
          fantasy_team: {
            name:              this.teamName,
            budget_cents:      this.budget * 100,
            teams_players_ids: this.teamMembers.map((element) => element.id)
          }
        }
        this.$http.patch(localizeRoute(`/fantasy_teams/${fantasyTeamUuid}.json`), payload).then(function(data) {
          window.location = data.body.redirect_path
        })
      }
    }
  })
})

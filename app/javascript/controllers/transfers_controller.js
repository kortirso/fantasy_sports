import * as Vue from "vue"

import { localizeValue, localizeRoute } from "utils/localize"
import { showAlerts } from "utils/alerts"
import { sportsData } from "utils/sports"

const transfersViewSelector = "#fantasy-team-transfers"

const element = document.querySelector(transfersViewSelector)
if (element !== null) {
  const seasonId = element.dataset.seasonId
  const sportKind = element.dataset.sportKind
  const fantasyTeamUuid = element.dataset.fantasyTeamUuid

  const playerSortParams = [
    "points"
  ]

  const app = Vue.createApp({
    data() {
      return {
        teamName: "My team",
        teams: [],
        teamsById: {},
        sportsPositions: [],
        sportsPositionsByKind: {},
        teamsPlayers: [],
        teamMembers: [],
        existedTeamMembers: [],
        budget: parseFloat(element.dataset.fantasyTeamBudget),
        completed: element.dataset.fantasyTeamCompleted === 'true',
        filterByPositionIsOpen: false,
        filterByPosition: null,
        filterByTeamIsOpen: false,
        filterByTeam: null,
        sortByIsOpen: false,
        sortBy: "points",
        sortByNameValues: {
          "points": { "en": "Total points", "ru": "Сумма очков" },
          "price": { "en": "Price", "ru": "Цена" }
        }
      }
    },
    created() {
      this.getTeams()
      this.getSportsPositions()
      this.getTeamsPlayers()

      if (this.completed) this.getFantasyTeamPlayers()
    },
    computed: {
      filterByPositionValue() {
        if (this.filterByPosition) return localizeValue(this.filterByPosition.name)

        return localizeValue({ "en": "All players", "ru": "Все игроки" })
      },
      filterByTeamValue() {
        if (this.filterByTeam) return localizeValue(this.filterByTeam.name)

        return localizeValue({ "en": "All teams", "ru": "Все команды" })
      },
      filteredTeamsPlayers() {
        return this.teamsPlayers.filter((element) => {
          if (this.filterByPosition !== null && this.filterByPosition.position_kind !== element.player.position_kind) return false
          if (this.filterByTeam !== null && this.filterByTeam.id !== element.team.id) return false

          return true
        }).sort((a, b) => {
          if (playerSortParams.includes(this.sortBy)) {
            return a.player[this.sortBy] < b.player[this.sortBy]
          } else {
            return a[this.sortBy] < b[this.sortBy]
          }
        })
      },
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
            _this.teams = data.teams.data.map((element) => {
              _this.teamsById[element.id] = element.attributes.name
              return element.attributes
            })
          })
      },
      getSportsPositions() {
        Object.entries(sportsData.positions).forEach(([positionKind, element]) => {
          if (element.sport_kind !== sportKind) return

          element.position_kind = positionKind
          this.sportsPositions.push(element)
          this.sportsPositionsByKind[positionKind] = { name: element.name, totalAmount: element.total_amount }
        })
      },
      getTeamsPlayers() {
        const _this = this
        fetch(localizeRoute(`/seasons/${seasonId}/players.json?fields=season_statistic`))
          .then(response => response.json())
          .then(function(data) {
            _this.teamsPlayers = data.season_players.data.map((element) => element.attributes)
          })
      },
      getFantasyTeamPlayers() {
        const _this = this
        fetch(localizeRoute(`/fantasy_teams/${fantasyTeamUuid}/players.json`))
          .then(response => response.json())
          .then(function(data) {
            _this.teamMembers = data.teams_players.data.map((element) => element.attributes)
          })
      },
      teamNameById(teamId) {
        return this.teamsById[teamId]
      },
      sportPositionByKind(sportPositionKind) {
        return this.sportsPositionsByKind[sportPositionKind]
      },
      addTeamMember(teamPlayer) {
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
      removeTeamMember(teamPlayer) {
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
      resetTransfers() {
        this.getFantasyTeamPlayers()
        this.budget = parseFloat(element.dataset.fantasyTeamBudget)
      },
      updateBudget(value) {
        this.budget += value
      },
      teamMembersForPosition(sportPositionKind) {
        return this.teamMembers.filter((element) => {
          return element.player.position_kind === sportPositionKind
        })
      },
      playerInTheTeam(teamPlayer) {
        return this.teamMembers.includes(teamPlayer)
      },
      submit() {
        if (this.completed) {
          const onlyValidate = false

          const payload = {
            fantasy_team: {
              teams_players_ids: this.teamMembers.map((element) => element.id),
              only_validate:     onlyValidate
            }
          }
          fetch(
            localizeRoute(`/fantasy_teams/${fantasyTeamUuid}/transfers.json`),
            {
              method:  "PATCH",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").getAttribute("content")
              },
              body:    JSON.stringify(payload)
            }
          )
            .then(response => response.json())
            .then(function(data) {
              if (onlyValidate) {
                if (data.result) {
                  showAlerts("notice", `<p>Points penalty - ${data.result.points_penalty}</p>`)
                } else {
                  data.errors.forEach((error) => showAlerts("alert", `<p>${error}</p>`))
                }
              } else {
                if (data.result) {
                  showAlerts("notice", `<p>${data.result}</p>`)
                } else {
                  data.errors.forEach((error) => showAlerts("alert", `<p>${error}</p>`))
                }
              }
            })
        } else {
          const payload = {
            fantasy_team: {
              name:              this.teamName,
              budget_cents:      this.budget * 100,
              teams_players_ids: this.teamMembers.map((element) => element.id)
            }
          }
          fetch(
            localizeRoute(`/fantasy_teams/${fantasyTeamUuid}.json`),
            {
              method:  "PATCH",
              headers: {
                "Content-Type": "application/json",
                "X-CSRF-TOKEN": document.querySelector("meta[name='csrf-token']").getAttribute("content")
              },
              body:    JSON.stringify(payload)
            }
          )
            .then(response => response.json())
            .then(function(data) {
              if (data.redirect_path) {
                window.location = data.redirect_path
              } else {
                data.errors.forEach((error) => showAlerts("alert", `<p>${error}</p>`))
              }
            })
        }
      },
      closeAllSelects() {
        this.filterByPositionIsOpen = false
        this.filterByTeamIsOpen = false
        this.sortByIsOpen = false
      },
      toggleSelect(value) {
        const currentValue = this[value]
        this.closeAllSelects()
        this[value] = !currentValue
      },
      selectFilterByPosition(value = null) {
        this.filterByPosition = value
        this.filterByPositionIsOpen = false
      },
      selectFilterByTeam(value = null) {
        this.filterByTeam = value
        this.filterByTeamIsOpen = false
      },
      selectSortBy(value) {
        this.sortBy = value
        this.sortByIsOpen = false
      }
    }
  })
  app.mount(transfersViewSelector)
}

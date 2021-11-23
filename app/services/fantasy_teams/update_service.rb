# frozen_string_literal: true

module FantasyTeams
  class UpdateService
    prepend ApplicationService

    def initialize(
      fantasy_team_validator: FantasyTeamValidator,
      transfers_validator:    FantasyTeams::Players::TransfersValidator
    )
      @fantasy_team_validator = fantasy_team_validator
      @transfers_validator    = transfers_validator
    end

    def call(fantasy_team:, params:)
      @fantasy_team = fantasy_team

      validate_params(fantasy_team_params(params))
      return if failure?

      validate_players(params[:teams_players_ids])
      return if failure?

      @fantasy_team.update(fantasy_team_params(params))
      create_fantasy_teams_players(params[:teams_players_ids])
    end

    private

    def fantasy_team_params(params)
      params.slice(:name).merge(completed: true)
    end

    def validate_params(params)
      fails!(@fantasy_team_validator.call(params: params))
    end

    def validate_players(teams_players_ids)
      fails!(@transfers_validator.call(fantasy_team: @fantasy_team, teams_players_ids: teams_players_ids))
    end

    def create_fantasy_teams_players(teams_players_ids)
      FantasyTeams::Player.upsert_all(
        teams_players_ids.map { |teams_player_id|
          { teams_player_id: teams_player_id, fantasy_team_id: @fantasy_team.id }
        }
      )
    end
  end
end

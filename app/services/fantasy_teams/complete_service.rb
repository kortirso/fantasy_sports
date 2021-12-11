# frozen_string_literal: true

module FantasyTeams
  class CompleteService
    prepend ApplicationService

    def initialize(
      fantasy_team_validator: FantasyTeamValidator,
      transfers_validator:    FantasyTeams::Players::TransfersValidator,
      lineup_creator:         Lineups::CreateService
    )
      @fantasy_team_validator = fantasy_team_validator
      @transfers_validator    = transfers_validator
      @lineup_creator         = lineup_creator
    end

    def call(fantasy_team:, params:, teams_players_ids:)
      @fantasy_team = fantasy_team

      validate_params(params)
      return if failure?

      validate_players(teams_players_ids)
      return if failure?

      ActiveRecord::Base.transaction do
        @fantasy_team.update(params.merge(completed: true))
        create_fantasy_teams_players(teams_players_ids)
        @lineup_creator.call(fantasy_team: @fantasy_team)
      end
    end

    private

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

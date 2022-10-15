# frozen_string_literal: true

module FantasyTeams
  class CompleteService
    prepend ApplicationService

    def initialize(
      fantasy_team_validator: FantasyTeamValidator,
      transfers_validator:    FantasyTeams::Players::TransfersValidator,
      lineup_creator:         ::Lineups::CreateService
    )
      @fantasy_team_validator = fantasy_team_validator
      @transfers_validator    = transfers_validator
      @lineup_creator         = lineup_creator
    end

    def call(fantasy_team:, params:, teams_players_ids: nil)
      @fantasy_team = fantasy_team

      return if validate_params(params.except(:favourite_team_id)) && failure?
      return if validate_players(teams_players_ids) && failure?

      complete_fantasy_team(params, teams_players_ids)
    end

    private

    def validate_params(params)
      fails!(@fantasy_team_validator.call(params: params))
    end

    def validate_players(teams_players_ids)
      fails!(@transfers_validator.call(fantasy_team: @fantasy_team, teams_players_ids: teams_players_ids))
    end

    def complete_fantasy_team(params, teams_players_ids)
      ActiveRecord::Base.transaction do
        @fantasy_team.update!(params.except(:favourite_team_id).merge(completed: true))
        create_fantasy_teams_players(teams_players_ids)
        create_fantasy_teams_transfers(teams_players_ids)
        @lineup_creator.call(fantasy_team: @fantasy_team)
        attach_fantasy_team_to_team_league(params[:favourite_team_id])
      end
    end

    def create_fantasy_teams_players(teams_players_ids)
      FantasyTeams::Player.upsert_all(
        teams_players_ids.map { |teams_player_id|
          { teams_player_id: teams_player_id, fantasy_team_id: @fantasy_team.id }
        }
      )
    end

    def create_fantasy_teams_transfers(teams_players_ids)
      Transfer.upsert_all(
        teams_players_ids.map { |teams_player_id|
          {
            teams_player_id: teams_player_id,
            fantasy_team_id: @fantasy_team.id,
            week_id: week_id,
            direction: Transfer::IN
          }
        }
      )
    end

    def attach_fantasy_team_to_team_league(favourite_team_id)
      return if favourite_team_id.nil?

      team = ::Team.find_by(id: favourite_team_id)
      return if team.nil?

      team.fantasy_leagues.last&.fantasy_leagues_teams&.create!(pointable: @fantasy_team)
    end

    def week_id
      @week_id ||= @fantasy_team.fantasy_leagues.first.season.weeks.coming.first.id
    end
  end
end

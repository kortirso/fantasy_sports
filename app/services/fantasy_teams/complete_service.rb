# frozen_string_literal: true

module FantasyTeams
  class CompleteService
    prepend ApplicationService

    def initialize(
      fantasy_team_validator: FantasySports::Container['validators.fantasy_team'],
      transfers_validator:    FantasyTeams::Players::TransfersValidator.new,
      lineup_creator:         ::Lineups::CreateService,
      league_join_service:    FantasySports::Container['services.persisters.fantasy_teams.join_fantasy_league']
    )
      @fantasy_team_validator = fantasy_team_validator
      @transfers_validator    = transfers_validator
      @lineup_creator         = lineup_creator
      @league_join_service    = league_join_service
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
        # commento: fantasy_teams.budget_cents, fantasy_teams.completed
        @fantasy_team.update!(
          params.except(:favourite_team_uuid)
            .merge(
              completed: true,
              budget_cents: @fantasy_team.budget_cents - Teams::Player.where(id: teams_players_ids).sum(:price_cents)
            )
        )
        create_fantasy_teams_players(teams_players_ids)
        lineup = @lineup_creator.call(fantasy_team: @fantasy_team).result
        create_transfers(lineup, teams_players_ids)
        connect_fantasy_team_with_main_league
        attach_fantasy_team_to_team_league(params[:favourite_team_uuid])
      end
    end

    def create_fantasy_teams_players(teams_players_ids)
      FantasyTeams::Player.upsert_all(
        teams_players_ids.map { |teams_player_id|
          { teams_player_id: teams_player_id, fantasy_team_id: @fantasy_team.id }
        }
      )
    end

    def create_transfers(lineup, teams_players_ids)
      Transfer.upsert_all(
        teams_players_ids.map { |teams_player_id|
          {
            teams_player_id: teams_player_id,
            lineup_id: lineup.id,
            direction: Transfer::IN
          }
        }
      )
    end

    def connect_fantasy_team_with_main_league
      @league_join_service.call(
        fantasy_team: @fantasy_team,
        fantasy_league_uuid: @fantasy_team.season.fantasy_leagues.find_by(name: 'Overall').uuid
      )
    end

    def attach_fantasy_team_to_team_league(favourite_team_uuid)
      return if favourite_team_uuid.nil?

      team = ::Team.find_by(uuid: favourite_team_uuid)
      return if team.nil?

      @league_join_service.call(
        fantasy_team: @fantasy_team,
        fantasy_league_uuid: team.fantasy_leagues.last.uuid
      )
    end
  end
end

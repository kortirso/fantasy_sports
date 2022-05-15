# frozen_string_literal: true

module FantasyTeams
  class GenerateService
    prepend ApplicationService

    def initialize(
      fantasy_team_create_service:   ::FantasyTeams::CreateService,
      lineup_generate_service:       ::FantasyTeams::Lineups::GenerateService,
      fantasy_team_complete_service: ::FantasyTeams::CompleteService
    )
      @fantasy_team_create_service   = fantasy_team_create_service
      @lineup_generate_service       = lineup_generate_service
      @fantasy_team_complete_service = fantasy_team_complete_service
    end

    def call(season:, user:, favourite_team_id:)
      @season            = season
      @user              = user
      @favourite_team_id = favourite_team_id

      create_fantasy_team
      return if failure?

      find_teams_players_ids
      complete_fantasy_team
    end

    private

    def create_fantasy_team
      create_service_call = @fantasy_team_create_service.call(season: @season, user: @user)
      return fail!(I18n.t('services.fantasy_teams.create.exists')) if create_service_call.failure?

      @result = create_service_call.result
    end

    def find_teams_players_ids
      @lineup_generate_service_call = @lineup_generate_service.call(season: @season)
    end

    def complete_fantasy_team
      @fantasy_team_complete_service.call(
        fantasy_team:      @result,
        params:            {
          name:              @result.uuid,
          budget_cents:      @lineup_generate_service_call.budget_cents,
          favourite_team_id: @favourite_team_id
        },
        teams_players_ids: @lineup_generate_service_call.result
      )
    end
  end
end

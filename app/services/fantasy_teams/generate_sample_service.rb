# frozen_string_literal: true

module FantasyTeams
  class GenerateSampleService
    prepend ApplicationService

    def initialize(
      create_fantasy_team_service:   ::FantasyTeams::CreateService,
      generate_lineup_service:       ::FantasyTeams::Lineups::GenerateSampleService,
      complete_fantasy_team_service: ::FantasyTeams::CompleteService
    )
      @create_fantasy_team_service   = create_fantasy_team_service
      @generate_lineup_service       = generate_lineup_service
      @complete_fantasy_team_service = complete_fantasy_team_service
    end

    def call(season:, user:, favourite_team_id:)
      @season            = season
      @user              = user
      @favourite_team_id = favourite_team_id

      return if create_fantasy_team && failure?

      complete_fantasy_team
    end

    private

    def create_fantasy_team
      response = @create_fantasy_team_service.call(season: @season, user: @user)
      return fail!(I18n.t('services.fantasy_teams.create.exists')) if response.failure?

      @result = response.result
    end

    def complete_fantasy_team
      @complete_fantasy_team_service.call(
        fantasy_team:      @result,
        params:            {
          name:              generate_name,
          budget_cents:      generate_lineup_service_object.budget_cents,
          favourite_team_id: @favourite_team_id
        },
        teams_players_ids: generate_lineup_service_object.result
      )
    end

    def generate_name
      @result.uuid
    end

    def generate_lineup_service_object
      @generate_lineup_service_object ||= @generate_lineup_service.call(season: @season)
    end
  end
end

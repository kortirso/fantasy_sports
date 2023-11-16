# frozen_string_literal: true

module FantasyTeams
  class CreateService
    prepend ApplicationService

    def initialize(
      league_join_service: FantasySports::Container['services.persisters.fantasy_teams.join_fantasy_league'],
      publish_job: ::FantasyTeams::CreateJob
    )
      @league_join_service = league_join_service
      @publish_job = publish_job
    end

    def call(season:, user:)
      @season = season
      @user = user

      return if validate_fantasy_team_uniqueness && failure?

      create_fantasy_team
      publish_created_fantasy_team
    end

    private

    def validate_fantasy_team_uniqueness
      return unless @season.fantasy_teams.exists?(user: @user)

      fail!(I18n.t('services.fantasy_teams.create.exists'))
    end

    def create_fantasy_team
      @result = @user.fantasy_teams.create(
        name: 'My team',
        sport_kind: @season.league.sport_kind,
        available_chips: Sport.find_by(title: @season.league.sport_kind).chips,
        season: @season
      )
    end

    def publish_created_fantasy_team
      @publish_job.perform_later(id: @result.id)
    end
  end
end

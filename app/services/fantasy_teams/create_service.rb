# frozen_string_literal: true

module FantasyTeams
  class CreateService
    prepend ApplicationService

    def initialize(
      league_join_service: ::FantasyLeagues::JoinService,
      publish_job: ::FantasyTeams::CreateJob
    )
      @league_join_service = league_join_service
      @publish_job = publish_job
    end

    def call(season:, user:)
      @season = season
      @user = user

      return if validate_fantasy_team_uniqueness && failure?

      ActiveRecord::Base.transaction do
        create_fantasy_team
        connect_fantasy_team_with_main_league
      end
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

    def connect_fantasy_team_with_main_league
      @league_join_service.call(
        fantasy_team: @result,
        fantasy_league: @season.fantasy_leagues.find_by(name: 'Overall')
      )
    end

    def publish_created_fantasy_team
      @publish_job.perform_later(id: @result.id)
    end
  end
end

# frozen_string_literal: true

module FantasyTeams
  class CreateService
    prepend ApplicationService

    def call(season:, user:)
      @season = season
      @user   = user

      return if validate_fantasy_team_uniqueness && failure?

      @result = user.fantasy_teams.create(name: 'My team', sport_kind: season.league.sport_kind)
      connect_fantasy_team_with_main_league
    end

    private

    def validate_fantasy_team_uniqueness
      return unless @season.fantasy_teams.exists?(user: @user)

      fail!(I18n.t('services.fantasy_teams.create.exists'))
    end

    def connect_fantasy_team_with_main_league
      overall_fantasy_league = @season.fantasy_leagues.find_by(name: 'Overall')
      overall_fantasy_league.fantasy_leagues_teams.create(pointable: @result)
    end
  end
end

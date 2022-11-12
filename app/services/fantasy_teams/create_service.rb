# frozen_string_literal: true

module FantasyTeams
  class CreateService
    prepend ApplicationService

    def initialize(
      league_join_service: ::FantasyLeagues::JoinService
    )
      @league_join_service = league_join_service
    end

    def call(season:, user:)
      @season = season
      @user   = user

      return if validate_fantasy_team_uniqueness && failure?

      @result = user.fantasy_teams.create(
        name: 'My team',
        sport_kind: season.league.sport_kind,
        available_chips: Sports.sport(season.league.sport_kind)['chips']
      )
      connect_fantasy_team_with_main_league
    end

    private

    def validate_fantasy_team_uniqueness
      return unless @season.fantasy_teams.exists?(user: @user)

      fail!(I18n.t('services.fantasy_teams.create.exists'))
    end

    def connect_fantasy_team_with_main_league
      @league_join_service.call(
        fantasy_team: @result,
        fantasy_league: @season.fantasy_leagues.find_by(name: 'Overall')
      )
    end
  end
end

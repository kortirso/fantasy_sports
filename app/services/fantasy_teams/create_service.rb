# frozen_string_literal: true

module FantasyTeams
  class CreateService
    prepend ApplicationService

    def call(league:, user:)
      @league = league
      @user   = user

      validate_fantasy_team_uniqueness
      return if failure?

      @result = user.fantasy_teams.create(name: 'My team')
      connect_fantasy_team_with_main_league
    end

    private

    def validate_fantasy_team_uniqueness
      return unless @league.active_season.fantasy_teams.exists?(user: @user)

      fail!('Fantasy team is already exists')
    end

    def connect_fantasy_team_with_main_league
      overall_fantasy_league = @league.active_season.fantasy_leagues.find_by(name: 'Overall')
      overall_fantasy_league.fantasy_leagues_teams.create(fantasy_team: @result)
    end
  end
end

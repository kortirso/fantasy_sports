# frozen_string_literal: true

module FantasyLeagues
  class JoinsController < ApplicationController
    include Deps[join_fantasy_league: 'services.persisters.fantasy_teams.join_fantasy_league']

    before_action :find_fantasy_league
    before_action :validate_invite_code
    before_action :find_fantasy_team
    before_action :validate_fantasy_team_uniqueness

    def index
      join_fantasy_league.call(fantasy_team: @fantasy_team, fantasy_league: @fantasy_league)
      redirect_to(
        fantasy_team_fantasy_leagues_path(@fantasy_team.uuid),
        notice: t('controllers.fantasy_leagues.joins.success')
      )
    end

    private

    def find_fantasy_league
      @fantasy_league = FantasyLeague.invitational.find_by!(uuid: params[:fantasy_league_id])
    end

    def validate_invite_code
      return if @fantasy_league.invite_code && @fantasy_league.invite_code == params[:invite_code]

      redirect_to home_path, alert: t('controllers.fantasy_leagues.joins.invalid_code')
    end

    def find_fantasy_team
      @fantasy_team = @fantasy_league.season.fantasy_teams.find_by(user: Current.user)
      return if @fantasy_team

      redirect_to home_path, alert: t('controllers.fantasy_leagues.joins.no_team')
    end

    def validate_fantasy_team_uniqueness
      return unless FantasyLeagues::Team.exists?(fantasy_league: @fantasy_league, pointable: @fantasy_team)

      redirect_to home_path, alert: t('controllers.fantasy_leagues.joins.joined')
    end
  end
end

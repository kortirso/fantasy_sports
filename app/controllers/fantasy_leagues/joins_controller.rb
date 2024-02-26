# frozen_string_literal: true

module FantasyLeagues
  class JoinsController < ApplicationController
    include Deps[join_fantasy_league: 'services.persisters.fantasy_teams.join_fantasy_league']

    skip_before_action :authenticate
    skip_before_action :check_email_confirmation
    skip_before_action :check_email_ban
    before_action :remember_invite_code
    before_action :authenticate
    before_action :check_email_confirmation
    before_action :check_email_ban
    before_action :find_fantasy_league
    before_action :validate_invite_code
    before_action :find_fantasy_team

    def index
      result = join_fantasy_league.call(fantasy_team: @fantasy_team, fantasy_league_uuid: params[:fantasy_league_id])
      case result
      in { errors: errors } then redirect_to draft_players_path, alert: errors[0]
      else
        cookies.delete(:fantasy_sports_invite_code)
        redirect_to(
          fantasy_team_points_path(@fantasy_team.uuid),
          notice: t('controllers.fantasy_leagues.joins.success')
        )
      end
    end

    private

    def remember_invite_code
      cookies[:fantasy_sports_invite_code] = {
        value: params[:invite_code],
        expires: 1.week.from_now
      }
    end

    def find_fantasy_league
      @fantasy_league = FantasyLeague.invitational.find_by!(uuid: params[:fantasy_league_id])
    end

    def validate_invite_code
      return if @fantasy_league.invite_code && @fantasy_league.invite_code == params[:invite_code]

      redirect_to draft_players_path, alert: t('controllers.fantasy_leagues.joins.invalid_code')
    end

    def find_fantasy_team
      @fantasy_team = @fantasy_league.season.fantasy_teams.find_by(user: Current.user)
      return if @fantasy_team

      redirect_to draft_players_path, alert: t('controllers.fantasy_leagues.joins.no_team')
    end
  end
end

# frozen_string_literal: true

module FantasyTeams
  class FantasyLeaguesController < ApplicationController
    before_action :find_fantasy_team
    before_action :find_fantasy_leagues, only: %i[index]

    def index; end

    def create
      form = FantasyLeagues::CreateForm.call(
        fantasy_team: @fantasy_team,
        leagueable: Current.user,
        params: fantasy_league_params
      )
      if form.success?
        render json: { redirect_path: fantasy_team_fantasy_leagues_path(@fantasy_team.uuid) }, status: :ok
      else
        render json: { errors: t('controllers.fantasy_teams.fantasy_leagues.fail_create') }, status: :ok
      end
    end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
    end

    def find_fantasy_leagues
      @fantasy_leagues = @fantasy_team.fantasy_leagues
    end

    def fantasy_league_params
      params.require(:fantasy_league).permit(:name)
    end
  end
end

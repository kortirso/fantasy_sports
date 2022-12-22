# frozen_string_literal: true

module Admin
  module Seasons
    class GamesController < AdminController
      before_action :find_season
      before_action :find_games, only: %i[index]
      before_action :find_game, only: %i[edit update destroy]
      before_action :find_form_data, only: %i[new edit]

      def index; end

      def new
        @game = Game.new
      end

      def edit; end

      def create
        service_call = ::Games::CreateService.call(**game_create_params.to_h.symbolize_keys)
        if service_call.success?
          redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.create.success')
        else
          redirect_to new_admin_season_game_path(@season.uuid), alert: service_call.errors
        end
      end

      def update
        service_call = ::Games::UpdateService.call(game: @game, params: game_update_params.to_h.symbolize_keys)
        if service_call.success?
          redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.update.success')
        else
          redirect_to edit_admin_season_game_path(@season.uuid, @game.uuid), alert: service_call.errors
        end
      end

      def destroy
        @game.destroy
        redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.destroy.success')
      end

      private

      def find_season
        @season = Season.find_by!(uuid: params[:season_id])
      end

      def find_games
        @games = @season.games.order(id: :asc).includes(:week, [home_season_team: :team, visitor_season_team: :team])
      end

      def find_game
        @game = @season.games.find_by!(uuid: params[:id])
      end

      def find_form_data
        @weeks = @season.weeks.order(position: :asc).pluck(:position, :id)
        @season_teams = @season.seasons_teams.includes(:team)
      end

      def game_create_params
        params.require(:game).permit(:week_id, :home_season_team_id, :visitor_season_team_id, :source, :external_id)
      end

      def game_update_params
        params.require(:game).permit(:week_id, :source, :external_id)
      end
    end
  end
end

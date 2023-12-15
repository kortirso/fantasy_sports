# frozen_string_literal: true

module Admin
  module Seasons
    class GamesController < AdminController
      include Deps[
        create_form: 'forms.games.create',
        update_form: 'forms.games.update'
      ]

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
        case create_form.call(params: game_create_params.to_h.symbolize_keys)
        in { errors: errors } then redirect_to new_admin_season_game_path(@season.uuid), alert: errors
        else
          redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.create.success')
        end
      end

      def update
        case update_form.call(game: @game, params: game_update_params.to_h.symbolize_keys)
        in { errors: errors } then redirect_to edit_admin_season_game_path(@season.uuid, @game.uuid), alert: errors
        else
          redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.update.success')
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
        params.require(:game).permit(:week_id, :home_season_team_id, :visitor_season_team_id)
      end

      def game_update_params
        params.require(:game).permit(:week_id)
      end
    end
  end
end

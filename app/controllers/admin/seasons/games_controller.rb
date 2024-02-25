# frozen_string_literal: true

module Admin
  module Seasons
    class GamesController < Admin::BaseController
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
        # commento: games.week_id, games.home_season_team_id,
        # commento: games.season_id, games.visitor_season_team_id, games.start_at
        case create_form.call(params: game_create_params.to_h.symbolize_keys)
        in { errors: errors } then redirect_to new_admin_season_game_path(@season.uuid), alert: errors
        else
          redirect_to admin_season_games_path(@season.uuid), notice: t('controllers.admin.seasons.games.create.success')
        end
      end

      def update
        # commento: games.week_id, games.start_at
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

      # rubocop: disable Metrics/AbcSize
      def game_create_params
        params
          .require(:game)
          .permit(:home_season_team_id, :visitor_season_team_id)
          .to_h
          .merge(
            start_at: params[:game][:start_at].present? ? DateTime.parse(params[:game][:start_at]) : nil,
            week_id: params[:game][:week_id].presence,
            season_id: @season.id
          )
      end
      # rubocop: enable Metrics/AbcSize

      def game_update_params
        {
          start_at: params[:game][:start_at].present? ? DateTime.parse(params[:game][:start_at]) : nil,
          week_id: params[:game][:week_id].presence
        }
      end
    end
  end
end

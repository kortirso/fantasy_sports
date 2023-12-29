# frozen_string_literal: true

module Admin
  module Seasons
    class InjuriesController < AdminController
      include Deps[
        create_form: 'forms.injuries.create',
        update_form: 'forms.injuries.update'
      ]

      before_action :find_season
      before_action :find_seasons_injuries, only: %i[index]
      before_action :find_injury, only: %i[edit update destroy]

      def index; end

      def new
        @injury = Injury.new
      end

      def edit; end

      def create
        # commento: injuries.status, injuries.reason, injuries.return_at
        case create_form.call(params: injury_params)
        in { errors: errors } then redirect_to new_admin_season_injury_path(@season.id), alert: errors
        else redirect_to admin_season_injuries_path(@season.id)
        end
      end

      def update
        # commento: injuries.status, injuries.reason, injuries.return_at
        case update_form.call(injury: @injury, params: injury_params)
        in { errors: errors } then redirect_to edit_admin_season_injury_path(@season.id, @injury.id), alert: errors
        else redirect_to admin_season_injuries_path(@season.id)
        end
      end

      def destroy
        @injury.destroy
        redirect_to admin_season_injuries_path(@season.id)
      end

      private

      def find_season
        @season = Season.find(params[:season_id])
      end

      def find_seasons_injuries
        @injuries = @season.injuries.includes(players_season: :player)
      end

      def find_injury
        @injury = @season.injuries.find(params[:id])
      end

      # rubocop: disable Metrics/AbcSize
      def injury_params
        params
          .require(:injury)
          .permit(:status)
          .to_h
          .merge(
            reason: { en: params[:injury][:reason_en], ru: params[:injury][:reason_ru] }.compact,
            return_at: params[:injury][:return_at].present? ? DateTime.parse(params[:injury][:return_at]) : nil,
            players_season_id: players_season_id
          ).compact
      end
      # rubocop: enable Metrics/AbcSize

      def players_season_id
        teams_player_id = params[:injury][:teams_player_id]
        return unless teams_player_id

        Teams::Player.find(teams_player_id).players_season_id
      end
    end
  end
end

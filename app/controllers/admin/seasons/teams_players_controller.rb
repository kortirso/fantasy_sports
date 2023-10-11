# frozen_string_literal: true

module Admin
  module Seasons
    class TeamsPlayersController < AdminController
      include Deps[update_form: 'forms.teams.players.update']

      before_action :find_season
      before_action :find_teams_players, only: %i[index]
      before_action :find_teams_player, only: %i[edit update]

      def index; end

      def edit; end

      def update
        # commento: teams_players.active, teams_players.price_cents, teams_players.shirt_number, teams_players.form
        case update_form.call(teams_player: @teams_player, params: teams_player_update_params)
        in { errors: errors }
          redirect_to(
            edit_admin_season_teams_player_path(@season.uuid, @teams_player.uuid),
            alert: errors
          )
        else
          redirect_to(
            admin_season_teams_players_path(@season.uuid),
            notice: t('controllers.admin.seasons.teams_players.update.success')
          )
        end
      end

      private

      def find_season
        @season = Season.find_by!(uuid: params[:season_id])
      end

      def find_teams_players
        @sport_positions = Sports::Position.where(sport: @season.league.sport_kind).pluck(:title, :name).to_h
        @teams_players = @season.teams_players.order(id: :asc, active: :asc).includes(:player, seasons_team: :team)
      end

      def find_teams_player
        @teams_player = @season.teams_players.find_by!(uuid: params[:id])
      end

      def teams_player_update_params
        params.require(:teams_player).permit(:active, :price_cents, :shirt_number, :form).to_h.symbolize_keys
      end
    end
  end
end

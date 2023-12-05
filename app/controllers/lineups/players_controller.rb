# frozen_string_literal: true

module Lineups
  class PlayersController < ApplicationController
    include Maintenable

    before_action :find_user_lineup, only: %i[update]
    before_action :find_league, only: %i[update]
    before_action :validate_league_maintenance, only: %i[update]

    def update
      service_call = Lineups::Players::UpdateService.call(
        lineup: @lineup,
        lineups_players_params: lineups_players_params
      )
      if service_call.success?
        render json: { message: t('controllers.lineups.players.lineup_update') }, status: :ok
      else
        render json: { errors: service_call.errors }, status: :unprocessable_entity
      end
    end

    private

    def find_user_lineup
      @lineup = Current.user.lineups.find_by!(uuid: params[:lineup_id])
    end

    def find_league
      @league = @lineup.week.league
    end

    def lineups_players_params
      params
        .require(:lineup_players)
        .permit(data: [%i[uuid change_order status]])
        .to_h[:data]
        .map { |hash|
          hash['change_order'] = hash['change_order'].to_i
          hash.symbolize_keys
        }
    end
  end
end

# frozen_string_literal: true

module Lineups
  class PlayersController < ApplicationController
    before_action :find_lineup
    before_action :find_lineup_players, only: %i[show]

    def show
      render json: {
        lineup_players: Lineups::PlayerSerializer.new(
          @lineup_players,
          { params: { fields: request_fields, week_id: @lineup.week_id } }
        ).serializable_hash
      }, status: :ok
    end

    def update
      service_call = Lineups::Players::UpdateService.call(
        lineup:                @lineup,
        lineup_players_params: lineup_players_params[:data]
      )
      if service_call.success?
        render json: { errors: [] }, status: :ok
      else
        render json: { errors: service_call.errors }, status: :unprocessable_entity
      end
    end

    private

    def find_lineup
      @lineup = Current.user.lineups.find_by(id: params[:lineup_id])
    end

    def find_lineup_players
      @lineup_players = @lineup.lineups_players.includes(teams_player: [:player, :seasons_team])
    end

    def lineup_players_params
      params.require(:lineup_players).permit(data: [[:id, :active, :change_order]]).to_h
    end
  end
end

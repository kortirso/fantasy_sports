# frozen_string_literal: true

module Lineups
  class PlayersController < ApplicationController
    include Maintenable

    before_action :find_lineup
    before_action :find_lineup_players, only: %i[show]
    before_action :find_league, only: %i[update]
    before_action :validate_league_maintenance, only: %i[update]

    def show
      render json: {
        lineup_players: Lineups::PlayerSerializer.new(@lineup_players).serializable_hash
      }, status: :ok
    end

    def update
      service_call = Lineups::Players::UpdateService.call(
        lineup:                 @lineup,
        lineups_players_params: lineups_players_params
      )
      if service_call.success?
        render json: { message: t('controllers.lineups.players.lineup_update') }, status: :ok
      else
        render json: { errors: service_call.errors }, status: :unprocessable_entity
      end
    end

    private

    def find_lineup
      @lineup = Current.user.lineups.find(params[:lineup_id])
    end

    def find_lineup_players
      @lineup_players = @lineup.lineups_players.includes(teams_player: %i[player seasons_team])
    end

    def find_league
      @league = @lineup.week.league
    end

    def lineups_players_params
      params
        .require(:lineup_players)
        .permit(data: [%i[id active change_order]])
        .to_h[:data]
        .map { |hash|
          hash['id'] = hash['id'].to_i
          hash['active'] = hash['active'] == 'true' || hash['active'] == true
          hash['change_order'] = hash['change_order'].to_i
          hash
        }
    end
  end
end

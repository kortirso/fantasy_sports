# frozen_string_literal: true

module Weeks
  class TransfersController < ApplicationController
    before_action :find_week, only: %i[index]

    def index
      render json: {
        transfers_in: transfers_in,
        transfers_out: transfers_out
      }, status: :ok
    end

    private

    def find_week
      @week = Week.find_by!(uuid: params[:week_id])
    end

    def transfers_in
      find_transfers(@week.transfers.in)
    end

    def transfers_out
      find_transfers(@week.transfers.out)
    end

    def find_transfers(transfers_scope)
      transfers = transfers_scope.group(:teams_player_id).count.sort_by { |_k, v| -v }.first(10).to_h
      teams_players = Teams::Player.where(id: transfers.keys).includes(:player, seasons_team: :team)
      transfers.map do |teams_player_id, amount|
        [
          Controllers::Weeks::Transfers::IndexSerializer
            .new(teams_players.find { |e| e.id == teams_player_id })
            .serializable_hash,
          amount
        ]
      end
    end
  end
end

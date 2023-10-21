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
      return find_transfers(@week.teams_players.group(:id).count) if @week.previous.nil?

      find_transfers(@week.transfers.in.group(:teams_player_id).count)
    end

    def transfers_out
      return [] if @week.previous.nil?

      find_transfers(@week.transfers.out.group(:teams_player_id).count)
    end

    def find_transfers(grouped_teams_players_ids)
      transfers = grouped_teams_players_ids.sort_by { |_k, v| -v }.first(10).to_h
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

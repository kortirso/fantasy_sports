# frozen_string_literal: true

module Weeks
  class OpponentsController < ApplicationController
    skip_before_action :authenticate, only: %i[index]
    skip_before_action :check_email_confirmation, only: %i[index]
    before_action :find_week, only: %i[index]
    before_action :find_opponents, only: %i[index]

    def index
      render json: { opponents: @opponents }, status: :ok
    end

    private

    def find_week
      @week = Week.find_by!(uuid: params[:week_id])
    end

    def find_opponents
      @opponents = {}
      @week.games.includes(:home_season_team, :visitor_season_team).each do |game|
        update_opponents_from_game(game)
      end
    end

    def update_opponents_from_game(game)
      team1_uuid = game.home_season_team.team.uuid
      team2_uuid = game.visitor_season_team.team.uuid

      @opponents[team1_uuid] ? @opponents[team1_uuid].push(team2_uuid) : (@opponents[team1_uuid] = [team2_uuid])
      @opponents[team2_uuid] ? @opponents[team2_uuid].push(team1_uuid) : (@opponents[team2_uuid] = [team1_uuid])
    end
  end
end

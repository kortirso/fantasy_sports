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
      @week = Week.find_by(uuid: params[:week_id])
    end

    def find_opponents
      @opponents = {}
      @week.games.includes(:home_season_team, :visitor_season_team).each do |game|
        team1_id = game.home_season_team.team_id
        team2_id = game.visitor_season_team.team_id

        @opponents[team1_id] ? @opponents[team1_id].push(team2_id) : (@opponents[team1_id] = [team2_id])
        @opponents[team2_id] ? @opponents[team2_id].push(team1_id) : (@opponents[team2_id] = [team1_id])
      end
    end
  end
end

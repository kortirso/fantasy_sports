# frozen_string_literal: true

module Api
  module Frontend
    class FantasyTeamsController < ApplicationController
      before_action :find_fantasy_team

      def destroy
        @fantasy_team.destroy
        render json: { redirect_path: home_path }, status: :ok
      end

      private

      def find_fantasy_team
        @fantasy_team = current_user.fantasy_teams.find_by!(uuid: params[:id])
      end
    end
  end
end

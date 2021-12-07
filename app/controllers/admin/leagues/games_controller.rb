# frozen_string_literal: true

module Admin
  module Leagues
    class GamesController < AdminController
      before_action :find_league
      before_action :find_game

      def show; end

      private

      def find_league
        @league = League.find(params[:league_id])
      end

      def find_game
        @game = Game.find(params[:id])
      end
    end
  end
end

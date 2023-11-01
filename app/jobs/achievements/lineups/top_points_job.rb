# frozen_string_literal: true

module Achievements
  module Lineups
    class TopPointsJob < ApplicationJob
      queue_as :default

      def perform(week_id:)
        week = Week.find_by(id: week_id)
        return unless week

        week.fantasy_leagues.each do |fantasy_league|
          fantasy_league.lineups
            .includes(fantasy_team: :user)
            .order(points: :desc).first(1000)
            .each.with_index(1) do |lineup, index|
              Achievement.award(:basketball_top_lineup, index, lineup.fantasy_team.user)
            end
        end
      end
    end
  end
end

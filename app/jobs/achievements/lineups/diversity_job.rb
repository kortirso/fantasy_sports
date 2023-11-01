# frozen_string_literal: true

module Achievements
  module Lineups
    class DiversityJob < ApplicationJob
      queue_as :default

      def perform(week_id:)
        week = Week.find_by(id: week_id)
        return unless week

        @sport = Sport.find_by(title: week.season.league.sport_kind)

        week.lineups.each { |lineup| award_lineup_user(lineup) }
      end

      private

      def award_lineup_user(lineup)
        user = lineup.fantasy_team.user
        teams_players = lineup.teams_players.hashable_pluck(:seasons_team_id, :shirt_number_string)

        seasons_team_ids = teams_players.pluck(:seasons_team_id)
        award_for_no_one_team_players(seasons_team_ids, user)
        award_for_team_of_friends(seasons_team_ids, user)

        shirt_numbers = teams_players.map { |e| e[:shirt_number_string].to_i }.sort
        award_for_team_of_twins(shirt_numbers, user)
        award_for_straight_players(shirt_numbers, user)
      end

      def award_for_no_one_team_players(seasons_team_ids, user)
        Achievement.award(:no_one_team_players, user) if seasons_team_ids.size == seasons_team_ids.uniq.size
      end

      def award_for_team_of_friends(seasons_team_ids, user)
        Achievement.award(:team_of_friends, user) if min_different_teams == seasons_team_ids.uniq.size
      end

      def award_for_team_of_twins(shirt_numbers, user)
        Achievement.award(:team_of_twins, user) if shirt_numbers.uniq.size == 1
      end

      def award_for_straight_players(shirt_numbers, user)
        return unless shirt_numbers.max - shirt_numbers.min == max_players - 1

        Achievement.award(:straight_players, user)
      end

      def min_different_teams = max_players / @sport.max_team_players
      def max_players = @sport.max_players
    end
  end
end

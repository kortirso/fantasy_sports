# frozen_string_literal: true

module Weeks
  class BenchSubstitutionsService
    def initialize(
      bench_substitutions_service: Lineups::BenchSubstitutionsService
    )
      @bench_substitutions_service = bench_substitutions_service
    end

    def call(week:)
      return unless Sport.find_by(title: week.league.sport_kind).changes

      lineups = week.lineups.without_final_points.load
      return if lineups.blank?

      lineups.each do |lineup|
        @bench_substitutions_service.call(lineup: lineup)
      end

      ::Lineups::Players::Points::UpdateJob.perform_later(
        team_player_ids: week.teams_players.ids,
        week_id: week.id,
        final_points: true
      )
    end
  end
end

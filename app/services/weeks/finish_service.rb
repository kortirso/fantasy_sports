# frozen_string_literal: true

module Weeks
  class FinishService
    prepend ApplicationService

    def initialize(
      bench_substitutions_service: Lineups::BenchSubstitutionsService
    )
      @bench_substitutions_service = bench_substitutions_service
    end

    def call(week:)
      return if week.nil?
      return unless week.active?

      # commento: weeks.status
      week.update!(status: Week::FINISHED)
      make_bench_substitutions(week)
    end

    private

    def make_bench_substitutions(week)
      return unless Sport.find_by(title: week.league.sport_kind).changes

      week.lineups.each do |lineup|
        @bench_substitutions_service.call(lineup: lineup)
      end

      ::Lineups::Players::Points::UpdateJob.perform_later(
        team_player_ids: week.teams_players.ids,
        week_id: week.id
      )
    end
  end
end

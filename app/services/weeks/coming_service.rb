# frozen_string_literal: true

module Weeks
  class ComingService
    prepend ApplicationService

    def initialize(
      lineup_create_service: Lineups::CreateService,
      games_players_create_service: FantasySports::Container['services.games.players.create_for_game'],
      update_game_difficulties_job: Games::DifficultyUpdateJob
    )
      @lineup_create_service = lineup_create_service
      @games_players_create_service = games_players_create_service
      @update_game_difficulties_job = update_game_difficulties_job
    end

    def call(week:)
      return if week.nil?
      return unless week.inactive?

      # commento: weeks.status
      week.update!(status: Week::COMING)
      create_games_players(week)
      create_lineups(week)
      update_game_difficulties(week)
    end

    private

    def create_games_players(week)
      week.games.each { |game| @games_players_create_service.call(game: game) }
    end

    def create_lineups(week)
      week.season.fantasy_teams.completed.find_each { |fantasy_team|
        @lineup_create_service.call(fantasy_team: fantasy_team, week: week)
      }
    end

    def update_game_difficulties(week)
      @update_game_difficulties_job.perform_later(week_id: week.id)
    end
  end
end

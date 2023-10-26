# frozen_string_literal: true

module Games
  class CreateService
    prepend ApplicationService
    include Validateable

    GAMES_PLAYERS_AVAILABLE = %w[active coming].freeze

    def initialize(
      games_players_create_service: FantasySports::Container['services.games.players.create_for_game']
    )
      @games_players_create_service = games_players_create_service
    end

    def call(params:)
      return if validate_with(validator, params) && failure?

      ActiveRecord::Base.transaction do
        create_game(params)
        create_games_players
      end
    end

    private

    def create_game(...)
      @result = Game.create!(...)
    end

    def create_games_players
      # only for active or coming weeks
      @games_players_create_service.call(game: @result) if GAMES_PLAYERS_AVAILABLE.include?(@result.week.status)
    end

    def validator = FantasySports::Container['validators.games.create']
  end
end

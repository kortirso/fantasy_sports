# frozen_string_literal: true

module Games
  class CreateForm
    include Deps[
      validator: 'validators.games.create',
      create_for_game: 'services.games.players.create_for_game'
    ]

    GAMES_PLAYERS_AVAILABLE = %w[active coming].freeze

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        game = create_game(params)
        create_games_players(game)
        game
      end

      { result: result }
    end

    private

    def create_game(...)
      # commento: games.source, games.external_id, games.week_id
      # commento: games.home_season_team_id, games.visitor_season_team_id
      Game.create!(...)
    end

    def create_games_players(game)
      # only for active or coming weeks
      create_for_game.call(game: game) if GAMES_PLAYERS_AVAILABLE.include?(game.week.status)
    end
  end
end

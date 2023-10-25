# frozen_string_literal: true

module Games
  class ImportService
    prepend ApplicationService

    SCRAPERS = {
      'basketball' => {
        'sportradar' => Basketball::SportradarScraper,
        'balldontlie' => Basketball::BalldontlieScraper
      },
      'football' => {
        'instat' => Football::InstatScraper
      }
    }.freeze

    def initialize(
      game_update_operation: ::Games::UpdateOperation
    )
      @game_update_operation = game_update_operation
    end

    def call(game:)
      scraper = find_scraper(game)
      return unless scraper

      @game_update_operation.call(game: game, game_data: fetch_game_data(scraper, game))
    end

    private

    def find_scraper(game)
      SCRAPERS.dig(game.week.league.sport_kind, game.source)
    end

    def fetch_game_data(scraper, game)
      scraper.new.call(external_id: game.external_id)
    end
  end
end

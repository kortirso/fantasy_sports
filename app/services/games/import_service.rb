# frozen_string_literal: true

module Games
  class ImportService
    prepend ApplicationService

    InvalidScrapingError = Class.new(StandardError)

    SCRAPERS = {
      'basketball' => {
        'sportradar' => Scrapers::Basketball::Sportradar,
        'balldontlie' => Scrapers::Basketball::Balldontlie
      },
      'football' => {
        'instat' => Scrapers::Football::Instat,
        'sports' => Scrapers::Football::Sports
      }
    }.freeze

    def initialize(
      update_service: ::Games::UpdateService
    )
      @update_service = update_service
    end

    def call(game:)
      scraper = find_scraper(game)
      return unless scraper

      @update_service.call(game: game, game_data: fetch_game_data(scraper, game))
    rescue InvalidScrapingError => _e
      # for invalid scraping just skip game fetching, retry will help
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

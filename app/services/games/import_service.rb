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

    def call(game:, main_external_source:)
      scraper = find_scraper(game, main_external_source)
      return unless scraper

      external_source = find_external_source(game, main_external_source)
      return unless external_source

      @update_service.call(game: game, game_data: fetch_game_data(scraper, game, external_source))
    rescue InvalidScrapingError => _e
      # for invalid scraping just skip game fetching, retry will help
    end

    private

    def find_scraper(game, main_external_source)
      SCRAPERS.dig(game.week.league.sport_kind, main_external_source)
    end

    def find_external_source(game, main_external_source)
      external_sources = game.external_sources.load
      external_sources.find { |element| element.source == main_external_source }.presence || external_sources.first
    end

    def fetch_game_data(scraper, game, external_source)
      scraper.new.call(game: game, external_id: external_source.external_id)
    end
  end
end

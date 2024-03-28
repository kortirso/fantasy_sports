# frozen_string_literal: true

module Injuries
  class ImportService
    include Deps[sportsgambler: 'scrapers.injuries.sportsgambler']

    def call(season:)
      scraper = scrapers_mapper(season.league.slug)
      return unless scraper

      data = scraper.call(season: season)
      Injury.upsert_all(data) if data.any?
    end

    private

    def scrapers_mapper(league_slug)
      case league_slug
      when 'epl', 'la_liga', 'seria_a', 'bundesliga', 'rpl' then sportsgambler
      end
    end
  end
end

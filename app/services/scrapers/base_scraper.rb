# frozen_string_literal: true

module Scrapers
  class BaseScraper
    def initialize(url:, http_service: HttpService::Client)
      @http_service = http_service.new(url: url)
      @result = [{ points: nil, players: {} }, { points: nil, players: {} }]
    end

    private

    def fetch_data(path)
      @http_service.get(path: path)
    end
  end
end

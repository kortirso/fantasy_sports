# frozen_string_literal: true

module Games
  class FetchService
    prepend ApplicationService

    def initialize(
      fetch_game_data_service: ::Import::FetchGameDataService,
      update_data_service: ::Games::UpdateDataService
    )
      @fetch_game_data_service = fetch_game_data_service
      @update_data_service = update_data_service
    end

    def call(game:)
      @update_data_service.call(game: game, game_data: fetch_game_data(game))
    end

    private

    def fetch_game_data(game)
      @fetch_game_data_service.call(
        external_id: game.external_id,
        fetcher_service: game.fetcher_service
      ).result
    end
  end
end

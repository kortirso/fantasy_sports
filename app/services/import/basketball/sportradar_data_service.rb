# frozen_string_literal: true

module Import
  module Basketball
    class SportradarDataService
      prepend ApplicationService

      def initialize(
        http_service: HttpService::Client.new(url: 'https://api.sportradar.com')
      )
        @http_service = http_service
        @api_key = Rails.application.credentials[:sportradar_api_key]
        @result = [{ points: nil, players: {} }, { points: nil, players: {} }]
      end

      def call(external_id:)
        data = fetch_data(external_id)

        parse_players_data(data)
        parse_game_data(data)
      end

      private

      def fetch_data(external_id)
        @http_service.get(path: "nba/trial/v7/en/games/#{external_id}/summary.json?api_key=#{@api_key}")
      end

      def parse_players_data(players_data)
        players_data['home']['players'].each { |data| parse_player_data(data, 0) }
        players_data['away']['players'].each { |data| parse_player_data(data, 1) }
      end

      def parse_player_data(player_data, team_index)
        @result[team_index][:players][player_data['jersey_number'].to_i] = {
          'P' => player_data.dig('statistics', 'points'),
          'REB' => player_data.dig('statistics', 'rebounds'),
          'A' => player_data.dig('statistics', 'assists'),
          'BLK' => player_data.dig('statistics', 'blocks'),
          'STL' => player_data.dig('statistics', 'steals'),
          'TO' => player_data.dig('statistics', 'turnovers')
        }
      end

      def parse_game_data(game_data)
        @result[0][:points] = game_data['home']['points']
        @result[1][:points] = game_data['away']['points']
      end
    end
  end
end

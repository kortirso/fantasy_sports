# frozen_string_literal: true

module Basketball
  class SportradarScraper < BaseScraper
    def initialize
      @api_key = Rails.application.credentials[:sportradar_api_key]

      super(url: 'https://api.sportradar.com')
    end

    def call(external_id:)
      data = fetch_data(external_id)

      parse_players_data(data)
      parse_game_data(data)
    end

    private

    def fetch_data(external_id)
      super("nba/trial/v8/en/games/#{external_id}/summary.json?api_key=#{@api_key}")
    end

    def parse_players_data(players_data)
      players_data['home']['players'].each { |data| parse_player_data(data, 0) }
      players_data['away']['players'].each { |data| parse_player_data(data, 1) }
    end

    def parse_player_data(player_data, team_index)
      @result[team_index][:players][player_data['jersey_number'].to_i] = {
        'MP' => transform_minutes_played(player_data.dig('statistics', 'minutes')),
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

    def transform_minutes_played(value)
      return 0 if value == '00:00'

      minutes = value.split(':').first.to_i
      minutes.zero? ? 1 : minutes
    end
  end
end

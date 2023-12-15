# frozen_string_literal: true

module Scrapers
  module Basketball
    class Sports < BaseScraper
      def initialize
        @api_key = Rails.application.credentials[:sports_api_key]

        super(url: 'https://v2.nba.api-sports.io')
      end

      def call(game:, external_id:)
        prepare_game_data(game)

        fetch_data(external_id).then { |data| parse_players_data(data['response']) }
        fetch_points_data(external_id).then { |data| parse_points_data(data.dig('response', 0)) }

        @result
      end

      private

      def fetch_data(external_id)
        @http_service.get(
          path: "players/statistics?game=#{external_id}",
          headers: { 'x-rapidapi-key' => @api_key, 'x-rapidapi-host' => 'v2.football.api-sports.io' }
        )
      end

      def fetch_points_data(external_id)
        @http_service.get(
          path: "games?id=#{external_id}",
          headers: { 'x-rapidapi-key' => @api_key, 'x-rapidapi-host' => 'v2.football.api-sports.io' }
        )
      end

      def parse_players_data(response)
        response.each { |data| parse_player_data(data) }
      end

      def parse_points_data(response)
        home_team_index = find_team_index(response.dig('teams', 'home', 'code'))
        visitor_team_index = find_team_index(response.dig('teams', 'visitors', 'code'))

        @result[home_team_index][:points] = response.dig('scores', 'home', 'points')
        @result[visitor_team_index][:points] = response.dig('scores', 'visitors', 'points')
      end

      # rubocop: disable Metrics/AbcSize
      def parse_player_data(player_data)
        team_index = find_team_index(player_data.dig('team', 'code'))
        shirt_number = find_shirt_number(
          team_index,
          player_data.dig('player', 'firstname'),
          transform_last_name(player_data.dig('player', 'lastname'))
        )
        return unless shirt_number

        @result[team_index][:players][shirt_number] = {
          'MP' => player_data['min'].to_i,
          'P' => player_data['points'],
          'REB' => player_data['totReb'],
          'A' => player_data['assists'],
          'BLK' => player_data['blocks'],
          'STL' => player_data['steals'],
          'TO' => player_data['turnovers']
        }
      end
      # rubocop: enable Metrics/AbcSize

      def prepare_game_data(game)
        @team_indexes = {
          game.home_season_team.team.short_name => 0,
          game.visitor_season_team.team.short_name => 1
        }
        @team_players = [
          game.home_season_team.teams_players
            .joins(:player).hashable_pluck(:shirt_number_string, 'players.first_name', 'players.last_name'),
          game.visitor_season_team.teams_players
            .joins(:player).hashable_pluck(:shirt_number_string, 'players.first_name', 'players.last_name')
        ]
      end

      def find_team_index(team_code)
        @team_indexes[team_code]
      end

      def find_shirt_number(team_index, first_name, last_name)
        result = @team_players[team_index].find { |element|
          element.dig(:players_first_name, 'en') == first_name && element.dig(:players_last_name, 'en') == last_name
        }
        return if result.nil?

        result[:shirt_number_string]
      end

      # TODO: think about better way to handle such last names
      def transform_last_name(value)
        case value
        when 'JacksonDavis' then 'Jackson-Davis'
        else value
        end
      end
    end
  end
end

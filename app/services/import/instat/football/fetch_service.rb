# frozen_string_literal: true

module Import
  module Instat
    module Football
      class FetchService
        prepend ApplicationService

        BONUS_POINTS_RANKS = {
          0 => 3,
          1 => 2,
          2 => 1
        }.freeze

        PARAMS_TO_STATS = {
          -1   => 'MP',
          25   => 'GS',
          64   => 'A',
          59   => 'GC',
          1030 => 'PS',
          32   => 'YC',
          33   => 'RC',
          58   => 'S',
          26   => 'S'
        }.freeze

        def initialize(
          http_service: HttpService::Client.new(url: 'https://api-football.instatscout.com')
        )
          @http_service = http_service

          @bonus_points_list = []
        end

        def call(external_id:)
          @external_id = external_id.to_i

          field_players_data = fetch_field_players_data
          goalie_players_data = fetch_goalie_players_data

          @result = [
            field_players_data[0].merge(goalie_players_data[0]),
            field_players_data[1].merge(goalie_players_data[1])
          ]

          calculate_bonus_points_for_players
          attach_bonus_points_to_players
        end

        private

        def fetch_field_players_data
          fetch_data(0)
            .then { |game_data| parse_data(game_data) }
        end

        def fetch_goalie_players_data
          fetch_data(1)
            .then { |game_data| parse_data(game_data) }
        end

        # rubocop: disable Metrics/AbcSize
        def calculate_bonus_points_for_players
          @awarded_players = []
          awarded_players_size = 0
          sorted_bonus_points  = @bonus_points_list.sort_by { |element| -element[2] }

          loop do
            points_value = sorted_bonus_points[awarded_players_size][2]
            points_bonus = BONUS_POINTS_RANKS[awarded_players_size]

            same_points_players = 1
            loop do
              break if sorted_bonus_points[same_points_players + awarded_players_size][2] != points_value

              same_points_players += 1
            end

            @awarded_players +=
              sorted_bonus_points[awarded_players_size...(awarded_players_size + same_points_players)]
              .map { |element| element.push(points_bonus) }

            awarded_players_size = @awarded_players.size
            break if awarded_players_size >= 3
          end
        end
        # rubocop: enable Metrics/AbcSize

        def attach_bonus_points_to_players
          @awarded_players.each do |player_info|
            @result[player_info[0]][player_info[1]]['B'] = player_info[3]
          end
        end

        # goalkeepers_data, 0 - field player, 1 - goalkeeper
        def fetch_data(goalkeepers_data)
          @http_service.post(
            path: '/widgets',
            body: {
              'sport'     => 'football',
              'widget_id' => 'scout_match_players_stat',
              'params'    => { '_p_is_gk' => goalkeepers_data, '_p_lang' => 'ru', '_p_match_id' => @external_id }
            }
          )['data'][0]['scout_match_players_stat']
        end

        def parse_data(game_data)
          [
            parse_players_data(game_data['team1_stat'], 0),
            parse_players_data(game_data['team2_stat'], 1)
          ]
        end

        def parse_players_data(players_data, team_index)
          result = {}
          players_data.each do |player_data|
            result[player_data['shirt_num']] = parse_player_data(player_data, team_index)
          end
          result
        end

        def parse_player_data(player_data, team_index)
          player_data['params'].each_with_object(default_stats) do |values, acc|
            next update_bonus_points(team_index, player_data['shirt_num'], values['value']) if values['param'].zero?

            stat_param = PARAMS_TO_STATS[values['param']]
            next if stat_param.nil?

            acc[stat_param] += values['value']
          end
        end

        def update_bonus_points(team_index, shirt_num, bonus_points)
          @bonus_points_list.push([team_index, shirt_num, bonus_points])
        end

        def default_stats
          Statable::FOOTBALL_STATS.index_with(0)
        end
      end
    end
  end
end

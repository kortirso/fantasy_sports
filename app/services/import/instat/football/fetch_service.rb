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
          -1 => 'MP',
          25 => 'GS',
          64 => 'A',
          59 => 'GC',
          1030 => 'PS',
          32 => 'YC',
          33 => 'RC',
          58 => 'S',
          26 => 'S'
        }.freeze

        def initialize(
          http_service: HttpService::Client.new(url: 'https://api-football.instatscout.com')
        )
          @http_service = http_service

          @bonus_points_list = []
          @goals_conceded_by_team = []
        end

        def call(external_id:)
          @external_id = external_id.to_i

          field_players_data = fetch_field_players_data
          goalie_players_data = fetch_goalie_players_data
          check_clean_sheet_from_goalies(goalie_players_data)

          @result = [
            update_field_players_goals_stats(field_players_data[0], 0)
              .merge(goalie_players_data[0]),
            update_field_players_goals_stats(field_players_data[1], 1)
              .merge(goalie_players_data[1])
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

        def check_clean_sheet_from_goalies(goalie_players_data)
          goalie_players_data.each do |team_data|
            @goals_conceded_by_team.push(
              team_data.values.sum { |player_data| player_data['GC'] }
            )
          end
        end

        def update_field_players_goals_stats(players_stats, team_index)
          players_stats.transform_values do |value|
            value['GC'] = @goals_conceded_by_team[team_index]
            value['CS'] = @goals_conceded_by_team[team_index].zero? ? 1 : 0
            value
          end
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
        # response example
        # {
        #   "team1_id" => 72,
        #   "team2_id" => 6,
        #   "team1_stat" => [
        #     {
        #       "f_player" => 159170,
        #       "shirt_num" => 13,
        #       "name_eng" => "Ігор Калінін",
        #       "name_rus" => "Игорь Калинин",
        #       "short_name_eng" => "I. Kalinin",
        #       "short_name_rus" => "Игорь Калинин",
        #       "params" => [
        #         {
        #           "param" => -1,
        #           "option" => 0,
        #           "value" => 98,
        #         },
        #         {
        #           "param" => 0,
        #           "option" => 0,
        #           "value" => 192,
        #         },
        #       ]
        #     }
        #   ]
        # }
        def fetch_data(goalkeepers_data)
          @http_service.post(
            path: '/widgets',
            body: {
              'sport' => 'football',
              'widget_id' => 'scout_match_players_stat',
              'params' => { '_p_is_gk' => goalkeepers_data, '_p_lang' => 'ru', '_p_match_id' => @external_id }
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

        # rubocop: disable Metrics/AbcSize
        def parse_player_data(player_data, team_index)
          player_data['params'].each_with_object(default_stats) do |values, acc|
            # update array for checking bonus points for all players of the game
            next update_bonus_points(team_index, player_data['shirt_num'], values['value']) if values['param'].zero?

            stat_param = PARAMS_TO_STATS[values['param']]
            next if stat_param.nil?

            # update clean sheet for goalies
            acc['CS'] = (values['value'].zero? ? 1 : 0) if stat_param == 'GC'

            acc[stat_param] += values['value']
          end
        end
        # rubocop: enable Metrics/AbcSize

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

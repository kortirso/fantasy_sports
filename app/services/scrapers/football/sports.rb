# frozen_string_literal: true

module Scrapers
  module Football
    class Sports < BaseScraper
      NAME_MAPPER = {
        'English Premier League' => {
          'Tottenham' => 'TOT',
          'Arsenal' => 'ARS',
          'Manchester City' => 'MCI',
          'Liverpool' => 'LIV',
          'Aston Villa' => 'AVL',
          'Newcastle' => 'NEW',
          'Brighton' => 'BHA',
          'Manchester United' => 'MAN',
          'West Ham' => 'WHU',
          'Brentford' => 'BRE',
          'Chelsea' => 'CHE',
          'Wolves' => 'WOL',
          'Crystal Palace' => 'CRY',
          'Fulham' => 'FUL',
          'Everton' => 'EVE',
          'Nottingham Forest' => 'NOT',
          'Bournemouth' => 'BOR',
          'Luton' => 'LUT',
          'Burnley' => 'BUR',
          'Sheffield Utd' => 'SHE'
        },
        'Seria A' => {
          'Bologna' => 'BOL',
          'AC Milan' => 'MIL',
          'Empoli' => 'EMP',
          'Verona' => 'VER',
          'Frosinone' => 'FRO',
          'Napoli' => 'NAP',
          'Genoa' => 'GEN',
          'Fiorentina' => 'FIO',
          'Inter' => 'INT',
          'Monza' => 'MNZ',
          'Lecce' => 'LEC',
          'Lazio' => 'LAZ',
          'AS Roma' => 'ROM',
          'Salernitana' => 'SAL',
          'Sassuolo' => 'SAS',
          'Atalanta' => 'ATA',
          'Torino' => 'TOR',
          'Cagliari' => 'CAG',
          'Udinese' => 'UDI',
          'Juventus' => 'JUV'
        },
        'Russian Premier League' => {
          'Spartak Moscow' => 'SPK',
          'Orenburg' => 'ORB',
          'FC Rostov' => 'ROS',
          'Fakel Voronezh' => 'FAK',
          'Dinamo Moscow' => 'DIN',
          'Krasnodar' => 'KRA',
          'Lokomotiv Moscow' => 'LOK',
          'Rubin' => 'RUB',
          'Akhmat Grozny' => 'AKH',
          'Krylya Sovetov' => 'KRS',
          'PFC Sochi' => 'SOC',
          'Baltika' => 'BAL',
          'Nizhny Novgorod' => 'NVG',
          'Zenit Saint Petersburg' => 'ZEN',
          'Ural' => 'URA',
          'CSKA Moscow' => 'CSK'
        },
        'La Liga' => {
          'Alaves' => 'ALA',
          'Almeria' => 'ALM',
          'Athletic Club' => 'ATH',
          'Atletico Madrid' => 'ATL',
          'Barcelona' => 'BAR',
          'Real Betis' => 'BET',
          'Valencia' => 'VAL',
          'Villarreal' => 'VIL',
          'Granada CF' => 'GRA',
          'Girona' => 'GIR',
          'Cadiz' => 'CAD',
          'Las Palmas' => 'LAS',
          'Mallorca' => 'MAL',
          'Osasuna' => 'OSA',
          'Rayo Vallecano' => 'RAY',
          'Real Madrid' => 'RLM',
          'Real Sociedad' => 'RLS',
          'Celta Vigo' => 'CEL',
          'Getafe' => 'GET',
          'Sevilla' => 'SEV'
        },
        'Bundesliga' => {
          'Eintracht Frankfurt' => 'EIN',
          'FC Augsburg' => 'AUG',
          'Bayern Munich' => 'BRN',
          'Bayer Leverkusen' => 'BAY',
          'Borussia Dortmund' => 'BRD',
          'Borussia Monchengladbach' => 'BRM',
          'VfL BOCHUM' => 'BCH',
          'Werder Bremen' => 'WER',
          'VfL Wolfsburg' => 'WLF',
          'SV Darmstadt 98' => 'DRM',
          'FC Koln' => 'KLN',
          'FSV Mainz 05' => 'MAI',
          'RB Leipzig' => 'LPZ',
          'Union Berlin' => 'UNI',
          'SC Freiburg' => 'FRE',
          'FC Heidenheim' => 'HEI',
          '1899 Hoffenheim' => 'HOF',
          'VfB Stuttgart' => 'STG'
        }
      }.freeze

      EVENT_MAPPER = {
        'Normal Goal' => 0,
        'Own Goal' => 1,
        'Penalty' => 2,
        'Missed Penalty' => 3,
        'Yellow Card' => 4,
        'Red Card' => 5,
        'Substitution' => 6
      }.freeze

      def initialize
        @api_key = Rails.application.credentials[:sports_api_key]
        @players_minutes = { 0 => {}, 1 => {} }
        @player_ids = { 0 => {}, 1 => {} }
        @players_statistic = {}

        super(url: 'https://v3.football.api-sports.io')
      end

      def call(game:, external_id:)
        @game = game

        fetch_data(external_id)

        update_players_minutes
        sort_ratings
        update_players_statistic
        update_game_points
        update_player_bonuses

        @result
      end

      private

      def fetch_data(external_id)
        parse_lineups(fetch_lineups(external_id))
        parse_events(fetch_events(external_id))
        parse_statistics(fetch_statistic(external_id))
      end

      def fetch_lineups(external_id)
        @http_service.get(
          path: "fixtures/lineups?fixture=#{external_id}",
          headers: { 'x-rapidapi-key' => @api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
        )
      end

      def fetch_events(external_id)
        @http_service.get(
          path: "fixtures/events?fixture=#{external_id}",
          headers: { 'x-rapidapi-key' => @api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
        )
      end

      def fetch_statistic(external_id)
        @http_service.get(
          path: "fixtures/players?fixture=#{external_id}",
          headers: { 'x-rapidapi-key' => @api_key, 'x-rapidapi-host' => 'v3.football.api-sports.io' }
        )
      end

      def parse_lineups(data)
        parse_lineup(data.dig('response', 0))
        parse_lineup(data.dig('response', 1))
      end

      def parse_lineup(data)
        raise Games::ImportService::InvalidScrapingError if data.nil?

        team_index = find_team_index(NAME_MAPPER[league_name][data.dig('team', 'name')])
        data['startXI'].each { |player_data| parse_lineup_player_data(player_data, team_index) }
        data['substitutes'].each { |player_data| parse_lineup_player_data(player_data, team_index, false) }
      end

      def find_team_index(short_name)
        case short_name
        when home_team_name then 0
        when visitor_team_name then 1
        end
      end

      # rubocop: disable Style/OptionalBooleanParameter
      def parse_lineup_player_data(player_data, team_index, from_start=true)
        shirt_number_string = player_data.dig('player', 'number').to_s
        @player_ids[team_index][player_data.dig('player', 'id')] = shirt_number_string
        return unless from_start

        @players_minutes[team_index][shirt_number_string] = {
          from: 0,
          until: nil
        }
      end
      # rubocop: enable Style/OptionalBooleanParameter

      def parse_events(data)
        response = data['response']
        raise Games::ImportService::InvalidScrapingError if data.blank?

        @events = response.filter_map { |event_data| parse_event(event_data) }
      end

      def parse_event(data)
        type = data['type'] == 'subst' ? EVENT_MAPPER['Substitution'] : EVENT_MAPPER[data['detail']]
        team_index = find_team_index(NAME_MAPPER[league_name][data.dig('team', 'name')])

        # change team index for own goals
        team_index = team_index.zero? ? 1 : 0 if type == 1
        minute = data.dig('time', 'elapsed')
        return if minute.negative?

        {
          minute: minute,
          team_index: team_index,
          player_id: data.dig('player', 'id'),
          player_assist_id: data.dig('assist', 'id'),
          type: type
        }
      end

      def parse_statistics(data)
        parse_statistic(data.dig('response', 0))
        parse_statistic(data.dig('response', 1))
      end

      def parse_statistic(data)
        raise Games::ImportService::InvalidScrapingError if data.nil?

        team_index = find_team_index(NAME_MAPPER[league_name][data.dig('team', 'name')])
        data['players'].each { |player_data| parse_player_statistic(player_data, team_index) }
      end

      def parse_player_statistic(player_data, team_index)
        shirt_number_string = @player_ids[team_index][player_data.dig('player', 'id')]

        @players_statistic["#{team_index}-#{shirt_number_string}"] = {
          rating: player_data.dig('statistics', 0, 'games', 'rating').to_f,
          saves: player_data.dig('statistics', 0, 'goals', 'saves').to_i
        }
      end

      def update_players_minutes
        [0, 1].each do |team_index|
          @events.each do |event|
            next if event[:team_index] != team_index
            next if [5, 6].exclude?(event[:type])

            # substitutions and red cards have influence on player time
            update_substitution_players(team_index, event)
          end
        end
      end

      # rubocop: disable Metrics/AbcSize
      def update_substitution_players(team_index, event)
        player_off = @player_ids[team_index][event[:player_id]]
        player_in = event[:player_assist_id].nil? ? nil : @player_ids[team_index][event[:player_assist_id]]

        if @players_minutes[team_index][player_off].nil?
          player_off = event[:player_assist_id].nil? ? nil : @player_ids[team_index][event[:player_assist_id]]
          player_in = @player_ids[team_index][event[:player_id]]
        end

        @players_minutes[team_index][player_off][:until] = event[:minute] if @players_minutes[team_index][player_off]
        return unless player_in

        @players_minutes[team_index][player_in] = {
          from: event[:minute],
          until: nil
        }
      end
      # rubocop: enable Metrics/AbcSize

      def sort_ratings
        @players_statistic = @players_statistic.sort do |element1, element2|
          element2.dig(1, :rating) <=> element1.dig(1, :rating)
        end.to_h
      end

      def update_players_statistic
        [0, 1].each do |team_index|
          opponent_team_index = team_index.zero? ? 1 : 0
          @players_minutes[team_index].each do |shirt_number_string, minutes|
            update_player_statistic(team_index, opponent_team_index, shirt_number_string, minutes)
          end
        end
      end

      # rubocop: disable Metrics/AbcSize
      def update_player_statistic(team_index, opponent_team_index, shirt_number_string, minutes)
        play_from = minutes[:from]
        play_until = minutes[:until].nil? ? 90 : minutes[:until]
        red_card = player_events(team_index, [5], shirt_number_string).any? ? 1 : 0
        goals_conceded = goal_conceded(play_from, play_until, red_card, team_index, opponent_team_index)

        @result[team_index][:players][shirt_number_string] = {
          'MP' => [play_until - play_from, 1].max,
          'GS' => player_events(team_index, [0, 2], shirt_number_string).size,
          'A' => player_assist_events(team_index, [0], shirt_number_string).size,
          'CS' => clean_sheet?(play_from, play_until, goals_conceded),
          'GC' => goals_conceded,
          'OG' => player_events(team_index, [1], shirt_number_string).size,
          'PS' => player_events(opponent_team_index, [3], shirt_number_string, [play_from, play_until]).size,
          'PM' => player_events(team_index, [3], shirt_number_string).size,
          # if player got 2 YC -> it is 1 RC
          'YC' => red_card.positive? ? 0 : player_events(team_index, [4], shirt_number_string).size,
          'RC' => red_card,
          'S' => @players_statistic.dig("#{team_index}-#{shirt_number_string}", :saves).to_i,
          'B' => 0
        }
      end
      # rubocop: enable Metrics/AbcSize

      def update_game_points
        [0, 1].each do |team_index|
          team_goals = @result[team_index][:players].values.sum { |e| e['GS'] }
          opponent_own_goals = @result[team_index.zero? ? 1 : 0][:players].values.sum { |e| e['OG'] }

          @result[team_index][:points] = team_goals + opponent_own_goals
        end
      end

      # { "#{team_index}-#{shirt_number_string}" => { :rating => 4 } }
      def update_player_bonuses
        @players_statistic.first(3).to_h.keys.each.with_index do |key, index|
          team_index, shirt_number_string = key.split('-')
          @result[team_index.to_i][:players][shirt_number_string]['B'] = 3 - index
        end
      end

      def clean_sheet?(play_from, play_until, goals)
        return 0 if play_until - play_from < 60

        goals.zero? ? 1 : 0
      end

      def goal_conceded(play_from, play_until, red_card, team_index, opponent_team_index)
        play_until = 90 if red_card == 1

        goals_opponent_team = player_events(opponent_team_index, [0, 2], nil, [play_from, play_until]).size
        own_goals = player_events(team_index, [1], nil, [play_from, play_until]).size

        goals_opponent_team + own_goals
      end

      # rubocop: disable Metrics/CyclomaticComplexity
      def player_events(team_index, types, shirt_number_string=nil, time_range=[])
        @events.select do |event|
          next false if event[:team_index] != team_index
          next false if types.exclude?(event[:type])
          next false if shirt_number_string && @player_ids[team_index][event[:player_id]] != shirt_number_string
          next true if time_range.blank?

          event[:minute] <= time_range.last && event[:minute] >= time_range.first
        end
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      def player_assist_events(team_index, types, shirt_number_string=nil)
        @events.select do |event|
          next false if event[:team_index] != team_index
          next false if types.exclude?(event[:type])
          next false if shirt_number_string && @player_ids[team_index][event[:player_assist_id]] != shirt_number_string

          true
        end
      end

      def league_name = @league_name ||= @game.week.season.league.name['en']
      def home_team_name = @home_team_name ||= @game.home_season_team.team.short_name
      def visitor_team_name = @visitor_team_name ||= @game.visitor_season_team.team.short_name
    end
  end
end

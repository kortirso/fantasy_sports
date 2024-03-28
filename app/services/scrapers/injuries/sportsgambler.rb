# frozen_string_literal: true

require 'nokogiri'

module Scrapers
  module Injuries
    class Sportsgambler
      include Deps[http_client: 'api.sportsgambler.client']

      LEAGUE_SLUG_MAPPER = {
        'epl' => 'england-premier-league',
        'la_liga' => 'spain-la-liga',
        'seria_a' => 'italy-serie-a',
        'bundesliga' => 'germany-bundesliga',
        'rpl' => 'russia-premier-league'
      }.freeze

      def call(season:)
        injuries_data = fetch_injuries_data(season)
        return if injuries_data.blank?

        teams_players = find_teams_players(season)
        existing_injuries = find_existing_injuries(teams_players.pluck(:players_season_id))
        teams_players.filter_map do |teams_player|
          next if existing_injuries.include?(teams_player[:players_season_id])

          injury_data = find_injury_data(injuries_data, teams_player)
          next unless injury_data

          return_at = convert_return_date(injury_data[:return_date], teams_player[:id])
          {
            players_season_id: teams_player[:players_season_id],
            reason: { en: injury_data[:info] },
            return_at: return_at,
            status: status_by_date(return_at)
          }
        end
      end

      private

      def fetch_injuries_data(season)
        league_name = LEAGUE_SLUG_MAPPER[season.league.slug]
        return [] unless league_name

        Nokogiri::HTML(fetch_data(league_name)).css('.inj-row .inj-container').map do |player|
          {
            name: data_from_field(player, '.inj-player'),
            info: data_from_field(player, '.inj-info'),
            return_date: data_from_field(player, '.inj-return')
          }
        end
      end

      def fetch_data(league_name)
        http_client.get_injuries(league_name: league_name)
      end

      def data_from_field(field, field_name)
        field.css(field_name).first.children.to_s
      end

      def find_teams_players(season)
        season
          .active_teams_players
          .joins(:player)
          .hashable_pluck(:id, :players_season_id, 'players.first_name', 'players.last_name', 'players.nickname')
          .map { |item|
            item[:name] = "#{item[:players_first_name]['en']} #{item[:players_last_name]['en']}"
            item
          }
      end

      def find_existing_injuries(players_season_ids)
        Injury
          .where(players_season_id: players_season_ids)
          .pluck(:players_season_id)
      end

      # rubocop: disable Metrics/CyclomaticComplexity
      def find_injury_data(injuries_data, teams_player)
        injuries_data.find do |item|
          next true if item[:name] == teams_player[:name]
          next true if item[:name] == teams_player[:players_nickname]['en']

          first_name = teams_player[:players_first_name]['en']
          next false if first_name && item[:name].exclude?(first_name)

          last_name = teams_player[:players_last_name]['en']
          next false if last_name && item[:name].exclude?(last_name)

          true
        end
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      def convert_return_date(value, teams_player_id)
        case value
        when 'A few days' then 3.days.after
        when 'A few weeks' then 15.days.after
        when 'Doubtful', 'Unknown' then nil
        when 'Out for season' then DateTime.new(2024, 6, 1)
        else convert_value(value, teams_player_id)
        end
      end

      # rubocop: disable Metrics/AbcSize
      def convert_value(value, teams_player_id)
        splitted = value.split
        return DateTime.new(2024, Date::MONTHNAMES.index(splitted[1]), 7) if splitted[0] == 'Early'
        return DateTime.new(2024, Date::MONTHNAMES.index(splitted[1]), 14) if splitted[0] == 'Mid'
        return DateTime.new(2024, Date::MONTHNAMES.index(splitted[1]), 21) if splitted[0] == 'Late'

        if splitted[0].to_i.positive?
          last_game_time = find_last_game_time(teams_player_id, splitted)
          return last_game_time + 1.day if last_game_time
        end

        nil
      end
      # rubocop: enable Metrics/AbcSize

      def find_last_game_time(teams_player_id, splitted)
        Teams::Player
          .find(teams_player_id)
          .games
          .where('start_at > ?', DateTime.now)
          .order(start_at: :asc)
          .limit(splitted[0])
          .pluck(:start_at)
          .last
      end

      def status_by_date(return_at)
        return 25 if return_at.nil?
        return 75 if return_at <= 1.week.after
        return 50 if return_at <= 2.weeks.after

        0
      end
    end
  end
end

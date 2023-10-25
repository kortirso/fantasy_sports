# frozen_string_literal: true

module Players
  class FindBestService
    def call(season:, week_uuid: nil)
      positions = Sports::Position.where(sport: season.league.sport_kind).pluck(:title, :default_amount).to_h
      result = collect_players_points(season, week_uuid, positions)
      return { output: [], ids: [] } if result.blank?

      transform_result(result, positions)
    end

    private

    def collect_players_points(season, week_uuid, positions, result={})
      games_players(season, week_uuid)
        .each_with_object({}) { |games_player, acc| increment_points_for_games_player(games_player, acc) }
        .group_by { |_, values| values[:players_position_kind] }
        .each { |position_kind, values| result[position_kind] = sort_by_points(values, positions[position_kind]) }
      result
    end

    def increment_points_for_games_player(element, acc)
      acc[element[:teams_player_id]] ||= { players_position_kind: element[:players_position_kind], points: 0 }
      acc[element[:teams_player_id]][:points] += element[:points].to_f
    end

    def sort_by_points(values, default_amount)
      values.sort_by { |element| -element.dig(1, :points) }.first(default_amount)
    end

    def games_players(season, week_uuid)
      Games::Player
        .joins(:game, teams_player: :player)
        .where(games: { week_id: weeks(season, week_uuid) })
        .hashable_pluck(:teams_player_id, 'players.position_kind', :points)
    end

    def transform_result(result, positions)
      ids = []
      output = positions.keys.flat_map do |position_kind|
        result[position_kind]&.map do |element|
          ids.push(element[0])
          [element[0], element[1][:points]]
        end
      end.compact

      {
        output: output,
        ids: ids
      }
    end

    def weeks(season, week_uuid)
      week_uuid ? find_week(season, week_uuid) : find_season_weeks(season)
    end

    def find_week(season, week_uuid)
      Week.where(season_id: season.id, uuid: week_uuid).select(:id)
    end

    def find_season_weeks(season)
      Week.where(season_id: season.id).select(:id)
    end
  end
end

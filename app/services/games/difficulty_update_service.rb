# frozen_string_literal: true

module Games
  class DifficultyUpdateService
    # week is coming
    def call(week:)
      objects = set_difficulties_for_next_weeks(
        week,
        generate_payload(week, week.season.league.points_system, week.season.members_count / 4)
      )
      # commento: games.difficulty
      Game.upsert_all(objects) if objects.any?
    end

    private

    def generate_payload(week, points_system, members_in_group)
      teams_with_points =
        Game
          .where(week_id: finished_week_ids(week))
          .hashable_pluck(:points, :home_season_team_id, :visitor_season_team_id)
          .each_with_object({}) do |game, acc|
            next if game[:points].blank?

            update_points_for_teams(
              game,
              points_for_game(game, points_system),
              acc
            )
          end

      sort_teams(teams_with_points, members_in_group)
    end

    def finished_week_ids(week)
      week.season.weeks.where(position: ...week.position - 1).select(:id)
    end

    def points_for_game(game, points_system)
      return [points_system['W'], points_system['L']] if game[:points][0] > game[:points][1]
      return [points_system['L'], points_system['W']] if game[:points][0] < game[:points][1]

      [points_system['D'], points_system['D']]
    end

    def update_points_for_teams(game, points_for_game, acc)
      acc[game[:home_season_team_id]] ||= 0
      acc[game[:home_season_team_id]] += points_for_game[0]
      acc[game[:visitor_season_team_id]] ||= 0
      acc[game[:visitor_season_team_id]] += points_for_game[1]
    end

    def sort_teams(teams_with_points, members_in_group)
      teams_with_points
        .sort_by { |_key, value| -value }
        .map.with_index { |team, index| [team[0], 5 - (index / members_in_group)] }
        .to_h
    end

    def set_difficulties_for_next_weeks(week, seasons_teams_difficulties)
      Game
        .where(week_id: next_week_ids(week))
        .hashable_pluck(:id, :week_id, :home_season_team_id, :visitor_season_team_id)
        .map do |game|
          game_payload(
            game,
            generate_difficulty(
              seasons_teams_difficulties[game[:home_season_team_id]] || 2,
              seasons_teams_difficulties[game[:visitor_season_team_id]] || 2
            )
          )
        end
    end

    def next_week_ids(week)
      week.season.weeks
        .where(position: week.position..week.position + 3)
        .select(:id)
    end

    def generate_difficulty(home_difficulty, visitor_difficulty)
      return [visitor_difficulty, home_difficulty] if home_difficulty != visitor_difficulty

      result = [home_difficulty, 3].max
      [result, result]
    end

    def game_payload(game, difficulty)
      {
        id: game[:id],
        week_id: game[:week_id],
        home_season_team_id: game[:home_season_team_id],
        visitor_season_team_id: game[:visitor_season_team_id],
        difficulty: difficulty
      }
    end
  end
end

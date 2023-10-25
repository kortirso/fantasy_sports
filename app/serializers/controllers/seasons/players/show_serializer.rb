# frozen_string_literal: true

module Controllers
  module Seasons
    module Players
      class ShowSerializer < Teams::PlayerSerializer
        attribute :games_players do |object|
          games_players =
            object
            .games_players
            .includes(:seasons_team, game: [:week, { home_season_team: :team, visitor_season_team: :team }])
            .where(weeks: { status: [Week::ACTIVE, Week::FINISHED] })
            .order(game_id: :desc)
          Games::PlayerSerializer.new(games_players).serializable_hash
        end

        attributes :teams_selected_by do |object|
          teams_count = object.seasons_team.season.fantasy_teams.count
          teams_count.zero? ? 0 : (100.0 * object.fantasy_teams.count / teams_count).round(1)
        end

        attributes :points_per_game do |object|
          played_games = object.games_players.pluck(:statistic).count { |statistic| statistic['MP'].to_i.positive? }
          played_games.zero? ? 0 : (object.player.points.to_f / played_games).round(1)
        end
      end
    end
  end
end

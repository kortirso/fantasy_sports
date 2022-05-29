# frozen_string_literal: true

module Teams
  module Players
    module Form
      class ChangeService
        prepend ApplicationService

        def call(games_ids:, seasons_teams_ids: [])
          points_data = points_data(games_ids, seasons_teams_ids)
          Teams::Player.where(id: points_data.keys).each do |teams_player|
            teams_player.update!(form: points_data[teams_player.id])
          end
        end

        private

        def points_data(games_ids, seasons_teams_ids)
          data = Games::Player.where(game_id: games_ids)
          unless seasons_teams_ids.empty?
            data = data.joins(:teams_player).where(teams_players: { seasons_team_id: seasons_teams_ids })
          end
          data.group(:teams_player_id).average(:points).transform_values(&:to_f)
        end
      end
    end
  end
end

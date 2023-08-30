# frozen_string_literal: true

module Teams
  module Players
    module Form
      class ChangeService
        prepend ApplicationService

        def call(games_ids:, seasons_teams_ids: [])
          points_data = points_data(games_ids, seasons_teams_ids)

          teams_players =
            Teams::Player
              .where(id: points_data.keys)
              .hashable_pluck(:id, :seasons_team_id, :player_id)
              .map do |teams_player|
                {
                  id: teams_player[:id],
                  form: points_data[teams_player[:id]],
                  seasons_team_id: teams_player[:seasons_team_id],
                  player_id: teams_player[:player_id]
                }
              end
          # commento: teams_players.form
          Teams::Player.upsert_all(teams_players) if teams_players.any?
        end

        private

        def points_data(games_ids, seasons_teams_ids)
          data = Games::Player.where(game_id: games_ids)
          unless seasons_teams_ids.empty?
            data = data.joins(:teams_player).where(teams_players: { seasons_team_id: seasons_teams_ids })
          end
          data.group(:teams_player_id).average(:points).transform_values { |points| points&.to_d&.round(1) || 0 }
        end
      end
    end
  end
end

# frozen_string_literal: true

module Controllers
  module FantasyTeams
    module Players
      class IndexSerializer < ::Players::SeasonSerializer
        attribute :fixtures do |object, params|
          seasons_team = object.active_teams_player.seasons_team

          # difficulties of next 4 games
          Rails.cache.fetch(
            ['fantasy_teams_players_team_fixtures_v1', seasons_team.id, params[:week_id]],
            expires_in: 12.hours,
            race_condition_ttl: 10.seconds
          ) do
            seasons_team
              .games
              .includes(:week, :home_season_team)
              .where('weeks.id >= ?', params[:week_id])
              .order('weeks.position ASC', 'start_at ASC')
              .limit(4)
              .hashable_pluck(:difficulty, :home_season_team_id)
              .map do |game|
                player_of_home_team = object.active_teams_player.seasons_team_id == game[:home_season_team_id]

                player_of_home_team ? game[:difficulty][0] : game[:difficulty][1]
              end
          end
        end

        attribute :last_points do |object, params|
          result = params[:last_points].find { |element| element[:teams_players_players_season_id] == object.id }
          result ? result[:points] : 0
        end
      end
    end
  end
end

# frozen_string_literal: true

module Controllers
  module Seasons
    module Players
      class ShowSerializer < ::Players::SeasonSerializer
        attributes :statistic

        attribute :games_players do |object|
          games_players =
            object
            .games_players
            .includes(:seasons_team, game: [:week, { home_season_team: :team, visitor_season_team: :team }])
            .where(weeks: { status: [Week::ACTIVE, Week::FINISHED] })
            .order('weeks.position DESC', 'games.start_at DESC')
          Games::PlayerSerializer.new(games_players).serializable_hash
        end

        # rubocop: disable Metrics/BlockLength
        attribute :fixtures do |object|
          week_ids = Week.where(season_id: object.season_id).future.order(position: :asc).limit(4).ids
          seasons_team = object.active_teams_player.seasons_team

          Rails.cache.fetch(
            ['seasons_team_fixtures_v1', seasons_team.id, week_ids],
            expires_in: 12.hours,
            race_condition_ttl: 10.seconds
          ) do
            seasons_team
              .games
              .includes(:week, [home_season_team: :team], [visitor_season_team: :team])
              .where(week_id: week_ids)
              .order('weeks.position ASC', 'start_at ASC')
              .map do |game|
                player_of_home_team = object.active_teams_player.seasons_team_id == game.home_season_team_id
                opponent_team_uuid =
                  player_of_home_team ? game.visitor_season_team.team.uuid : game.home_season_team.team.uuid

                {
                  uuid: game.uuid,
                  start_at: game.start_at,
                  week_position: game.week.position,
                  is_home_game: player_of_home_team,
                  opponent_team_uuid: opponent_team_uuid,
                  difficulty: player_of_home_team ? game.difficulty[0] : game.difficulty[1]
                }
              end
          end
        end
        # rubocop: enable Metrics/BlockLength

        attributes :teams_selected_by do |object|
          teams_count = object.active_teams_player.seasons_team.season.fantasy_teams.count
          teams_count.zero? ? 0 : (100.0 * object.active_teams_player.fantasy_teams.count / teams_count).round(1)
        end

        attribute :injury do |object|
          injury = object.injuries.active.last
          injury ? InjurySerializer.new(injury).serializable_hash : nil
        end
      end
    end
  end
end

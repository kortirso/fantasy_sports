# frozen_string_literal: true

module Games
  class CreateService
    prepend ApplicationService
    include Validateable

    def call(params)
      return if validate_with(validator, params) && failure?

      ActiveRecord::Base.transaction do
        create_game(params)
        create_games_players
      end
    end

    private

    def create_game(...)
      @result = Game.create!(...)
    end

    def create_games_players
      games_players = [@result.home_season_team, @result.visitor_season_team].flat_map do |season_team|
        season_team.active_teams_players
          .includes(:player)
          .hashable_pluck(:id, 'players.position_kind').map do |teams_player|
            {
              game_id: @result.id,
              teams_player_id: teams_player[:id],
              position_kind: teams_player[:players_position_kind],
              seasons_team_id: season_team.id
            }
          end
      end
      Games::Player.upsert_all(games_players) if games_players.any?
    end

    def validator = FantasySports::Container['validators.games.create']
  end
end

# frozen_string_literal: true

module Games
  class CreateService
    prepend ApplicationService
    include Validateable

    def initialize(game_validator: Games::CreateValidator)
      @game_validator = game_validator
    end

    def call(params)
      return if validate_with(@game_validator, params) && failure?

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
        season_team.active_teams_players.includes(:player).map do |teams_player|
          {
            teams_player_id: teams_player.id,
            position_kind: teams_player.player.position_kind
          }
        end
      end
      Games::Player.upsert_all(games_players) if games_players.any?
    end
  end
end

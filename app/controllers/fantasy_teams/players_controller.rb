# frozen_string_literal: true

module FantasyTeams
  class PlayersController < ApplicationController
    before_action :find_fantasy_team, only: %i[index]

    def index
      render json: { teams_players: teams_players }, status: :ok
    end

    private

    def find_fantasy_team
      @fantasy_team = Current.user.fantasy_teams.find_by!(uuid: params[:fantasy_team_id])
    end

    def teams_players
      Rails.cache.fetch(
        ['fantasy_teams_players_index_v2', @fantasy_team.id, @fantasy_team.updated_at],
        expires_in: 12.hours,
        race_condition_ttl: 10.seconds
      ) do
        players_season_id_ids = @fantasy_team.teams_players.active.select(:players_season_id)
        ::Players::SeasonSerializer.new(
          ::Players::Season
            .where(id: players_season_id_ids)
            .includes(:player, active_teams_player: [seasons_team: :team])
        ).serializable_hash
      end
    end
  end
end

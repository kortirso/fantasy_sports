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
        ['fantasy_teams_players_index_v4', @fantasy_team.id, @fantasy_team.updated_at],
        expires_in: 12.hours,
        race_condition_ttl: 10.seconds
      ) do
        players_season_id_ids = @fantasy_team.teams_players.active.select(:players_season_id)
        ::Players::SeasonSerializer.new(
          players(players_season_id_ids),
          params: { injuries: injuries(players_season_id_ids) }
        ).serializable_hash
      end
    end

    def players(players_season_id_ids)
      ::Players::Season.where(id: players_season_id_ids).includes(:player, active_teams_player: [seasons_team: :team])
    end

    def injuries(players_season_id_ids)
      Injury.where(players_season_id: players_season_id_ids).active.group_by(&:players_season_id)
    end
  end
end

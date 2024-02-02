# frozen_string_literal: true

module Lineups
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :change_order, :status

    attribute :active, &:active?

    attribute :points do |object|
      object.points.presence || '-'
    end

    attribute :teams_player do |object|
      {
        uuid: object.teams_player.uuid,
        shirt_number: object.teams_player.shirt_number_string
      }
    end

    attribute :player do |object, params|
      teams_player = object.teams_player
      player = teams_player.player
      players_season = teams_player.players_season
      injuries = params[:injuries][teams_player.players_season_id]
      {
        uuid: players_season.uuid,
        form: players_season.form,
        points: players_season.points,
        price: (teams_player.price_cents.to_i / 100.0).round(1),
        price_cents: teams_player.price_cents.to_i,
        name: player.name,
        shirt_name: player.shirt_name,
        position_kind: player.position_kind,
        injury: injuries.blank? ? nil : InjurySerializer.new(injuries[0]).serializable_hash
      }
    end

    attribute :team do |object|
      seasons_team = object.teams_player.seasons_team
      {
        uuid: seasons_team.team.uuid
      }
    end

    attribute :week_statistic, if: proc { |_, params| params_with_field?(params, 'week_statistic') } do |object, params|
      games_players = params[:games_players][object.teams_player_id] || []

      games_players.each_with_object({}) do |games_player, acc|
        acc.deep_merge!(games_player[:statistic]) { |_k, a_value, b_value|
          a_value + b_value
        }
      end
    end

    attribute :last_points, if: proc { |_, params| params[:last_points] } do |object, params|
      result = params[:last_points].find { |element| element[:teams_player_id] == object.id }

      result&.slice(:points, :status)
    end

    attribute :fixtures, if: proc { |_, params| params_with_field?(params, 'fixtures') } do |object|
      week_id = object.lineup.week_id
      seasons_team = object.teams_player.seasons_team

      # difficulties of games of this week
      Rails.cache.fetch(
        ['lineups_players_team_fixtures_v1', seasons_team.id, week_id],
        expires_in: 12.hours,
        race_condition_ttl: 10.seconds
      ) do
        seasons_team
          .games
          .includes(:home_season_team)
          .where(week_id: week_id)
          .order(start_at: :asc)
          .hashable_pluck(:difficulty, :home_season_team_id)
          .map do |game|
            player_of_home_team = seasons_team.id == game[:home_season_team_id]

            player_of_home_team ? game[:difficulty][0] : game[:difficulty][1]
          end
      end
    end
  end
end

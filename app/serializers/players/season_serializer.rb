# frozen_string_literal: true

module Players
  class SeasonSerializer < ApplicationSerializer
    attributes :uuid, :statistic

    attribute :form do |object|
      object.form.to_f
    end

    attribute :points do |object|
      object.points.to_f
    end

    attribute :average_points do |object|
      object.average_points.to_f
    end

    attribute :player do |object|
      player = object.player
      {
        name: player.name,
        shirt_name: player.shirt_name,
        position_kind: player.position_kind
      }
    end

    attribute :team do |object|
      active_teams_player = object.active_teams_player
      team = active_teams_player&.seasons_team&.team
      {
        uuid: team&.uuid,
        name: team&.name,
        price: (active_teams_player&.price_cents.to_i / 100.0).round(1),
        shirt_number: active_teams_player&.shirt_number_string
      }
    end

    attribute :injury do |object, params|
      injuries = params[:injuries][object.id]
      injuries.blank? ? nil : InjurySerializer.new(injuries[0]).serializable_hash
    end
  end
end

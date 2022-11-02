# frozen_string_literal: true

module Controllers
  module Weeks
    module Transfers
      class IndexSerializer < Teams::PlayerSerializer
        attribute :price do
          nil
        end

        attribute :player do |object|
          player = object.player
          {
            name: player.name,
            position_kind: player.position_kind
          }
        end

        attribute :team do |object|
          seasons_team = object.seasons_team
          {
            name: seasons_team.team.short_name
          }
        end
      end
    end
  end
end

# frozen_string_literal: true

class LineupSerializer < ApplicationSerializer
  attributes :uuid, :active_chips

  attribute :fantasy_team do |object|
    {
      available_chips: object.fantasy_team.available_chips
    }
  end
end

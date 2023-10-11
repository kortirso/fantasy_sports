# frozen_string_literal: true

class WeekSerializer < ApplicationSerializer
  attributes :uuid, :position, :deadline_at

  attribute :games, if: proc { |_, params| params_with_field?(params, 'games') } do |object|
    GameSerializer
      .new(object.games.includes(home_season_team: :team, visitor_season_team: :team)
      .order(start_at: :asc))
      .serializable_hash
  end

  attribute :previous, if: proc { |_, params| params_with_field?(params, 'previous') } do |object|
    {
      uuid: object.previous&.uuid
    }
  end

  attribute :next, if: proc { |_, params| params_with_field?(params, 'next') } do |object|
    {
      uuid: object.next&.uuid
    }
  end
end

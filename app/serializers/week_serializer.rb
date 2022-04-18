# frozen_string_literal: true

class WeekSerializer < ApplicationSerializer
  attributes :id, :position

  attribute :date_deadline_at do |object|
    object.deadline_at&.strftime('%d.%m.%Y')
  end

  attribute :time_deadline_at do |object|
    object.deadline_at&.strftime('%H:%M')
  end

  attribute :games, if: proc { |_, params| params_with_field?(params, 'games') } do |object|
    GameSerializer.new(object.games).serializable_hash
  end

  attribute :previous, if: proc { |_, params| params_with_field?(params, 'previous') } do |object|
    {
      id: object.previous&.id
    }
  end

  attribute :next, if: proc { |_, params| params_with_field?(params, 'next') } do |object|
    {
      id: object.next&.id
    }
  end
end

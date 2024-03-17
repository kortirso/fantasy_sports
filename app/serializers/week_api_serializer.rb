# frozen_string_literal: true

class WeekApiSerializer < ApplicationSerializer
  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :position, if: proc { |_, params| required_field?(params, 'position') }, &:position
  attribute :deadline_at, if: proc { |_, params| required_field?(params, 'deadline_at') }, &:deadline_at

  attribute :previous_id, if: proc { |_, params| required_field?(params, 'previous_id') } do |object|
    object.previous&.id
  end

  attribute :next_id, if: proc { |_, params| required_field?(params, 'next_id') } do |object|
    object.next&.id
  end
end

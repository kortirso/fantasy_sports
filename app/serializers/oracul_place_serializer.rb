# frozen_string_literal: true

class OraculPlaceSerializer < ApplicationSerializer
  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :placeable_id, if: proc { |_, params| required_field?(params, 'placeable_id') }, &:placeable_id
  attribute :placeable_type, if: proc { |_, params| required_field?(params, 'placeable_type') }, &:placeable_type

  attribute :name, if: proc { |_, params| required_field?(params, 'name') } do |object|
    object.name[I18n.locale.to_s]
  end
end

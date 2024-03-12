# frozen_string_literal: true

class OraculPlaceSerializer < ApplicationSerializer
  set_id :uuid

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :uuid, if: proc { |_, params| required_field?(params, 'uuid') }, &:uuid
  attribute :name, if: proc { |_, params| required_field?(params, 'name') }, &:name
  attribute :placeable_id, if: proc { |_, params| required_field?(params, 'placeable_id') }, &:placeable_id
  attribute :placeable_type, if: proc { |_, params| required_field?(params, 'placeable_type') }, &:placeable_type
end

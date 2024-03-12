# frozen_string_literal: true

class OraculSerializer < ApplicationSerializer
  set_id :uuid

  attribute :uuid, if: proc { |_, params| required_field?(params, 'uuid') }, &:uuid
  attribute :name, if: proc { |_, params| required_field?(params, 'name') }, &:name
  attribute :oracul_place_id, if: proc { |_, params| required_field?(params, 'oracul_place_id') }, &:oracul_place_id
end

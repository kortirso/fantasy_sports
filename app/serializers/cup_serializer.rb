# frozen_string_literal: true

class CupSerializer < ApplicationSerializer
  set_id :uuid

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :uuid, if: proc { |_, params| required_field?(params, 'uuid') }, &:uuid
  attribute :name, if: proc { |_, params| required_field?(params, 'name') }, &:name
  attribute :league_id, if: proc { |_, params| required_field?(params, 'league_id') }, &:league_id
end

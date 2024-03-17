# frozen_string_literal: true

class SeasonSerializer < ApplicationSerializer
  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :name, if: proc { |_, params| required_field?(params, 'name') }, &:name
  attribute :league_id, if: proc { |_, params| required_field?(params, 'league_id') }, &:league_id
end

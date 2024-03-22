# frozen_string_literal: true

class LeagueSerializer < ApplicationSerializer
  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :slug, if: proc { |_, params| required_field?(params, 'slug') }, &:slug
  attribute :sport_kind, if: proc { |_, params| required_field?(params, 'sport_kind') }, &:sport_kind

  attribute :name, if: proc { |_, params| required_field?(params, 'name') } do |object|
    object.name[I18n.locale.to_s]
  end
end

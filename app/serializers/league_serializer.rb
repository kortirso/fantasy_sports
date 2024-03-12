# frozen_string_literal: true

class LeagueSerializer < ApplicationSerializer
  extend Helpers::AccessToken
  extend ActionView::Helpers::AssetUrlHelper

  set_id :id

  attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
  attribute :name, if: proc { |_, params| required_field?(params, 'name') }, &:name
  attribute :sport_kind, if: proc { |_, params| required_field?(params, 'sport_kind') }, &:sport_kind

  attribute :background_url, if: proc { |_, params| required_field?(params, 'background_url') } do |object|
    image_url(object.background_url, host: Rails.application.routes.url_helpers.root_url).to_s
  end
end

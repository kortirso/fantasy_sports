# frozen_string_literal: true

module Cups
  class PairSerializer < ApplicationSerializer
    set_id :id

    attribute :id, if: proc { |_, params| required_field?(params, 'id') }, &:id
    attribute :points, if: proc { |_, params| required_field?(params, 'points') }, &:points
    attribute :start_at, if: proc { |_, params| required_field?(params, 'start_at') }, &:start_at
    attribute :predictable, if: proc { |_, params| required_field?(params, 'predictable') }, &:predictable?

    attribute :home_name, if: proc { |_, params| required_field?(params, 'home_name') } do |object|
      object.home_name ? object.home_name[I18n.locale.to_s] : nil
    end

    attribute :visitor_name, if: proc { |_, params| required_field?(params, 'visitor_name') } do |object|
      object.visitor_name ? object.visitor_name[I18n.locale.to_s] : nil
    end
  end
end

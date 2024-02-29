# frozen_string_literal: true

module Cups
  class PairSerializer < ApplicationSerializer
    attributes :uuid, :points, :start_at, :home_name, :visitor_name

    attribute :predictable, &:predictable?
  end
end

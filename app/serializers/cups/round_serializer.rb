# frozen_string_literal: true

module Cups
  class RoundSerializer < ApplicationSerializer
    attributes :uuid

    attribute :games do |object|
      Cups::PairSerializer
        .new(object.cups_pairs.order(start_at: :asc))
        .serializable_hash
    end
  end
end

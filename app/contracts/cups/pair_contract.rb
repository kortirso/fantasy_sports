# frozen_string_literal: true

module Cups
  class PairContract < ApplicationContract
    config.messages.namespace = :cups_pair

    params do
      optional(:home_name).value(:hash)
      optional(:visitor_name).value(:hash)
      optional(:start_at)
      optional(:points)
      optional(:elimination_kind)
      optional(:required_wins)
    end

    rule(:elimination_kind, :required_wins) do
      if values[:elimination_kind] == Cups::Pair::BEST_OF && values[:required_wins].blank?
        key(:required_wins).failure(:empty)
      end
    end
  end
end

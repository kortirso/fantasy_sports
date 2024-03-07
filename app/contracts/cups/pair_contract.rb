# frozen_string_literal: true

module Cups
  class PairContract < ApplicationContract
    config.messages.namespace = :cups_pair

    params do
      optional(:home_name).value(:hash)
      optional(:visitor_name).value(:hash)
      optional(:start_at)
      optional(:points)
    end
  end
end

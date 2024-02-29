# frozen_string_literal: true

module Cups
  class PairContract < ApplicationContract
    config.messages.namespace = :cups_pair

    params do
      optional(:home_name).filled(:string)
      optional(:visitor_name).filled(:string)
      optional(:start_at)
      optional(:points)
    end
  end
end

# frozen_string_literal: true

module Cups
  class RoundContract < ApplicationContract
    config.messages.namespace = :cups_round

    params do
      required(:name).filled(:string)
      required(:position).filled(:string)
    end
  end
end

# frozen_string_literal: true

module Cups
  module Rounds
    class UpdateContract < ApplicationContract
      config.messages.namespace = :cups_round

      params do
        optional(:name).filled(:string)
        optional(:position).filled(:string)
        optional(:status).filled(:string)
      end
    end
  end
end

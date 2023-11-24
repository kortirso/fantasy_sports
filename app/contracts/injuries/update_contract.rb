# frozen_string_literal: true

module Injuries
  class UpdateContract < ApplicationContract
    config.messages.namespace = :injury

    params do
      optional(:reason).value(:hash)
      optional(:status).value(:integer)
    end

    rule(:reason) do
      key.failure(:invalid) if values[:reason].values.any?(&:blank?)
    end
  end
end

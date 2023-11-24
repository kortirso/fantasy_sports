# frozen_string_literal: true

module Injuries
  class CreateContract < ApplicationContract
    config.messages.namespace = :injury

    params do
      required(:reason).value(:hash)
      required(:status).value(:integer)
    end

    rule(:reason) do
      key.failure(:invalid) if values[:reason].values.any?(&:blank?)
    end
  end
end

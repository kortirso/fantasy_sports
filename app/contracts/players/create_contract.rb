# frozen_string_literal: true

module Players
  class CreateContract < ApplicationContract
    config.messages.namespace = :player

    params do
      required(:first_name).value(:hash)
      required(:last_name).value(:hash)
      optional(:nickname).value(:hash)
      required(:position_kind).filled(:string)
    end

    rule(:first_name) do
      key.failure(:invalid) if values[:first_name].values.any?(&:blank?)
    end

    rule(:last_name) do
      key.failure(:invalid) if values[:last_name].values.any?(&:blank?)
    end

    rule(:position_kind) do
      key.failure(:invalid) if Sports::Position.pluck(:title).exclude?(values[:position_kind])
    end
  end
end

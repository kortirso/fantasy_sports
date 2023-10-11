# frozen_string_literal: true

module Players
  class CreateContract < ApplicationContract
    config.messages.namespace = :player

    params do
      required(:name).value(:hash)
      required(:position_kind).filled(:string)
    end

    rule(:name) do
      if values[:name].values.any?(&:blank?)
        key.failure(:invalid)
      end
    end

    rule(:position_kind) do
      if Sports::Position.pluck(:title).exclude?(values[:position_kind])
        key.failure(:invalid)
      end
    end
  end
end

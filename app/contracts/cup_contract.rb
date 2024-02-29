# frozen_string_literal: true

class CupContract < ApplicationContract
  config.messages.namespace = :cup

  params do
    required(:name).value(:hash)
  end

  rule(:name) do
    if values[:name].values.any?(&:blank?)
      key.failure(:invalid)
    end
  end
end

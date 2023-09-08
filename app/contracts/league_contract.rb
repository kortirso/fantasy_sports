# frozen_string_literal: true

class LeagueContract < ApplicationContract
  config.messages.namespace = :league

  params do
    required(:name).value(:hash)
    required(:sport_kind).filled(:string)
  end

  rule(:name) do
    if values[:name].values.any?(&:blank?)
      key.failure(:invalid)
    end
  end

  rule(:sport_kind) do
    if Sport.all.pluck(:title).exclude?(values[:sport_kind])
      key.failure(:invalid)
    end
  end
end

# frozen_string_literal: true

class FantasyLeagueContract < ApplicationContract
  config.messages.namespace = :fantasy_league

  params do
    optional(:id)
    required(:name).filled(:string)
  end
end

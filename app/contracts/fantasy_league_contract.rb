# frozen_string_literal: true

class FantasyLeagueContract < ApplicationContract
  config.messages.namespace = :fantasy_league

  params do
    required(:name).filled(:string)
  end
end

# frozen_string_literal: true

class FantasyTeamContract < ApplicationContract
  config.messages.namespace = :fantasy_team

  params do
    required(:name).filled(:string)
  end
end

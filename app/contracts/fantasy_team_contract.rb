# frozen_string_literal: true

class FantasyTeamContract < ApplicationContract
  config.messages.namespace = :fantasy_team

  schema do
    optional(:id)
    required(:name).filled(:string)
    required(:budget_cents).filled(:integer)
  end
end

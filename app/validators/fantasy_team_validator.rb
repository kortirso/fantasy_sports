# frozen_string_literal: true

class FantasyTeamValidator < ApplicationValidator
  def initialize(contract: FantasyTeamContract)
    @contract = contract
  end
end

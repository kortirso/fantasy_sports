# frozen_string_literal: true

class FantasyLeagueValidator < ApplicationValidator
  def initialize(contract: FantasyLeagueContract)
    @contract = contract
  end
end

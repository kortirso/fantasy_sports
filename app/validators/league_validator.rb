# frozen_string_literal: true

class LeagueValidator < ApplicationValidator
  def initialize(contract: LeagueContract)
    @contract = contract
  end
end

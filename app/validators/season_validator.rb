# frozen_string_literal: true

class SeasonValidator < ApplicationValidator
  def initialize(contract: SeasonContract)
    @contract = contract
  end
end

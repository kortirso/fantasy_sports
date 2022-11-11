# frozen_string_literal: true

module Games
  class CreateValidator < ApplicationValidator
    def initialize(contract: Games::CreateContract)
      @contract = contract
    end
  end
end

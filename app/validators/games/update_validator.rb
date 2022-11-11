# frozen_string_literal: true

module Games
  class UpdateValidator < ApplicationValidator
    def initialize(contract: Games::UpdateContract)
      @contract = contract
    end
  end
end

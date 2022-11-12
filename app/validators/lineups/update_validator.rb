# frozen_string_literal: true

module Lineups
  class UpdateValidator < ApplicationValidator
    def initialize(contract: Lineups::UpdateContract)
      @contract = contract
    end
  end
end

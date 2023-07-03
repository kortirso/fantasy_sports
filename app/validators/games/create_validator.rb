# frozen_string_literal: true

module Games
  class CreateValidator < ApplicationValidator
    def initialize(contract: Games::CreateContract)
      super
    end
  end
end

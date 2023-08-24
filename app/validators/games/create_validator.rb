# frozen_string_literal: true

module Games
  class CreateValidator < ApplicationValidator
    def contract
      Games::CreateContract
    end
  end
end

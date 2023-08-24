# frozen_string_literal: true

module Games
  class UpdateValidator < ApplicationValidator
    def contract
      Games::UpdateContract
    end
  end
end

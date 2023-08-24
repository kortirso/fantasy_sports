# frozen_string_literal: true

module Lineups
  class UpdateValidator < ApplicationValidator
    def contract
      Lineups::UpdateContract
    end
  end
end

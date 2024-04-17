# frozen_string_literal: true

module Cups
  module Rounds
    class UpdateValidator < ApplicationValidator
      include Deps[contract: 'contracts.cups.rounds.update']
    end
  end
end

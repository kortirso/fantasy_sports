# frozen_string_literal: true

module Games
  class UpdateValidator < ApplicationValidator
    include Deps[contract: 'contracts.games.update']
  end
end

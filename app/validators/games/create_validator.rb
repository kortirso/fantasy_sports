# frozen_string_literal: true

module Games
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.games.create']
  end
end

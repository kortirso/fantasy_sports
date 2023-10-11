# frozen_string_literal: true

module Teams
  module Players
    class CreateValidator < ApplicationValidator
      include Deps[contract: 'contracts.teams.players.create']
    end
  end
end

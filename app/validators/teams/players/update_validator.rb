# frozen_string_literal: true

module Teams
  module Players
    class UpdateValidator < ApplicationValidator
      include Deps[contract: 'contracts.teams.players.update']
    end
  end
end

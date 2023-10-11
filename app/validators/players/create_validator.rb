# frozen_string_literal: true

module Players
  class CreateValidator < ApplicationValidator
    include Deps[contract: 'contracts.players.create']
  end
end

# frozen_string_literal: true

module Lineups
  class UpdateValidator < ApplicationValidator
    include Deps[contract: 'contracts.lineups.update']
  end
end

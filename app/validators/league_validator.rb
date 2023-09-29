# frozen_string_literal: true

class LeagueValidator < ApplicationValidator
  include Deps[contract: 'contracts.league']
end

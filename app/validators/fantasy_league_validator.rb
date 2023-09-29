# frozen_string_literal: true

class FantasyLeagueValidator < ApplicationValidator
  include Deps[contract: 'contracts.fantasy_league']
end

# frozen_string_literal: true

class FantasyTeamValidator < ApplicationValidator
  include Deps[contract: 'contracts.fantasy_team']
end

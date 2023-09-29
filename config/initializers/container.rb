# frozen_string_literal: true

require 'dry/auto_inject'
require 'dry/container'

module FantasySports
  class Container
    extend Dry::Container::Mixin

    DEFAULT_OPTIONS = { memoize: true }.freeze

    class << self
      def register(key)
        super(key, DEFAULT_OPTIONS)
      end
    end

    # contracts
    register('contracts.games.create') { Games::CreateContract.new }
    register('contracts.games.update') { Games::UpdateContract.new }
    register('contracts.lineups.update') { Lineups::UpdateContract.new }
    register('contracts.users.create') { Users::CreateContract.new }
    register('contracts.users.update') { Users::UpdateContract.new }
    register('contracts.fantasy_league') { FantasyLeagueContract.new }
    register('contracts.fantasy_team') { FantasyTeamContract.new }
    register('contracts.league') { LeagueContract.new }
    register('contracts.season') { SeasonContract.new }

    # validators
    register('validators.games.create') { Games::CreateValidator.new }
    register('validators.games.update') { Games::UpdateValidator.new }
    register('validators.lineups.update') { Lineups::UpdateValidator.new }
    register('validators.users.create') { Users::CreateValidator.new }
    register('validators.users.update') { Users::UpdateValidator.new }
    register('validators.fantasy_league') { FantasyLeagueValidator.new }
    register('validators.fantasy_team') { FantasyTeamValidator.new }
    register('validators.league') { LeagueValidator.new }
    register('validators.season') { SeasonValidator.new }
  end
end

Deps = Dry::AutoInject(FantasySports::Container)

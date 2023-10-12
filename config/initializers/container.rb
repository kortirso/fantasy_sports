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

    register('jwt_encoder') { JwtEncoder.new }

    # contracts
    register('contracts.games.create') { Games::CreateContract.new }
    register('contracts.games.update') { Games::UpdateContract.new }
    register('contracts.lineups.update') { Lineups::UpdateContract.new }
    register('contracts.teams.players.create') { Teams::Players::CreateContract.new }
    register('contracts.teams.players.update') { Teams::Players::UpdateContract.new }
    register('contracts.users.create') { Users::CreateContract.new }
    register('contracts.users.update') { Users::UpdateContract.new }
    register('contracts.fantasy_league') { FantasyLeagueContract.new }
    register('contracts.fantasy_team') { FantasyTeamContract.new }
    register('contracts.league') { LeagueContract.new }
    register('contracts.season') { SeasonContract.new }
    register('contracts.players.create') { Players::CreateContract.new }

    # validators
    register('validators.games.create') { Games::CreateValidator.new }
    register('validators.games.update') { Games::UpdateValidator.new }
    register('validators.lineups.update') { Lineups::UpdateValidator.new }
    register('validators.teams.players.create') { Teams::Players::CreateValidator.new }
    register('validators.teams.players.update') { Teams::Players::UpdateValidator.new }
    register('validators.users.create') { Users::CreateValidator.new }
    register('validators.users.update') { Users::UpdateValidator.new }
    register('validators.fantasy_league') { FantasyLeagueValidator.new }
    register('validators.fantasy_team') { FantasyTeamValidator.new }
    register('validators.league') { LeagueValidator.new }
    register('validators.season') { SeasonValidator.new }
    register('validators.players.create') { Players::CreateValidator.new }

    # forms
    register('forms.teams.players.create') { Teams::Players::CreateForm.new }
    register('forms.teams.players.update') { Teams::Players::UpdateForm.new }
    register('forms.players.create') { Players::CreateForm.new }

    # services
    register('services.auth.fetch_session') { Auth::FetchSessionService.new }
    register('services.auth.generate_token') { Auth::GenerateTokenService.new }
    register('services.players.find_best') { Players::FindBestService.new }
  end
end

Deps = Dry::AutoInject(FantasySports::Container)

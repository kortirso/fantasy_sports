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
    register('to_bool') { ToBool.new }
    register('api.telegram.client') { TelegramApi::Client.new }
    register('api.google.auth_client') { GoogleAuthApi::Client.new }
    register('api.google.client') { GoogleApi::Client.new }

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
    register('contracts.feedback') { FeedbackContract.new }
    register('contracts.injuries.create') { Injuries::CreateContract.new }
    register('contracts.injuries.update') { Injuries::UpdateContract.new }
    register('contracts.identity') { IdentityContract.new }
    register('contracts.notification') { NotificationContract.new }
    register('contracts.banned_email') { BannedEmailContract.new }
    register('contracts.weeks.update') { Weeks::UpdateContract.new }
    register('contracts.oracul') { OraculContract.new }
    register('contracts.cup') { CupContract.new }
    register('contracts.cups.round') { Cups::RoundContract.new }
    register('contracts.cups.pair') { Cups::PairContract.new }

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
    register('validators.feedback') { FeedbackValidator.new }
    register('validators.injuries.create') { Injuries::CreateValidator.new }
    register('validators.injuries.update') { Injuries::UpdateValidator.new }
    register('validators.identity') { IdentityValidator.new }
    register('validators.notification') { NotificationValidator.new }
    register('validators.banned_email') { BannedEmailValidator.new }
    register('validators.weeks.update') { Weeks::UpdateValidator.new }
    register('validators.oracul') { OraculValidator.new }
    register('validators.cup') { CupValidator.new }
    register('validators.cups.round') { Cups::RoundValidator.new }
    register('validators.cups.pair') { Cups::PairValidator.new }

    # forms
    register('forms.teams.players.create') { Teams::Players::CreateForm.new }
    register('forms.teams.players.update') { Teams::Players::UpdateForm.new }
    register('forms.players.create') { Players::CreateForm.new }
    register('forms.players.update') { Players::UpdateForm.new }
    register('forms.fantasy_leagues.create') { FantasyLeagues::CreateForm.new }
    register('forms.leagues.create') { Leagues::CreateForm.new }
    register('forms.lineups.update') { Lineups::UpdateForm.new }
    register('forms.seasons.create') { Seasons::CreateForm.new }
    register('forms.users.create') { Users::CreateForm.new }
    register('forms.users.update') { Users::UpdateForm.new }
    register('forms.games.create') { Games::CreateForm.new }
    register('forms.games.update') { Games::UpdateForm.new }
    register('forms.feedbacks.create') { Feedbacks::CreateForm.new }
    register('forms.injuries.create') { Injuries::CreateForm.new }
    register('forms.injuries.update') { Injuries::UpdateForm.new }
    register('forms.identities.create') { Identities::CreateForm.new }
    register('forms.notifications.create') { Notifications::CreateForm.new }
    register('forms.banned_emails.create') { BannedEmails::CreateForm.new }
    register('forms.weeks.update') { Weeks::UpdateForm.new }
    register('forms.oraculs.create') { Oraculs::CreateForm.new }
    register('forms.oraculs.forecasts.update') { Oraculs::Forecasts::UpdateForm.new }
    register('forms.cups.create') { Cups::CreateForm.new }
    register('forms.cups.rounds.create') { Cups::Rounds::CreateForm.new }
    register('forms.cups.pairs.create') { Cups::Pairs::CreateForm.new }
    register('forms.cups.pairs.update') { Cups::Pairs::UpdateForm.new }

    # notifiers
    register('notifiers.telegram.user.deadline_report_payload') { Telegram::User::DeadlineReportPayload.new }

    # services
    register('services.converters.seconds_to_text') { Converters::SecondsToTextService.new }
    register('services.auth.providers.telegram') { Auth::Providers::Telegram.new }
    register('services.auth.providers.google') { Auth::Providers::Google.new }
    register('services.auth.fetch_session') { Auth::FetchSessionService.new }
    register('services.auth.generate_token') { Auth::GenerateTokenService.new }
    register('services.auth.attach_identity') { Auth::AttachIdentityService.new }
    register('services.auth.login_user') { Auth::LoginUserService.new }
    register('services.players.find_best') { Players::FindBestService.new }
    register('services.games.players.create_for_game') { Games::Players::CreateForGameService.new }
    register('services.fantasy_leagues.teams.update_current_place') {
      FantasyLeagues::Teams::CurrentPlaceUpdateService.new
    }
    register('services.persisters.fantasy_teams.join_fantasy_league') {
      Persisters::FantasyTeams::JoinFantasyLeagueService.new
    }
    register('services.persisters.oraculs.join_oracul_league') {
      Persisters::Oraculs::JoinOraculLeagueService.new
    }
    register('services.persisters.users.update') { Persisters::Users::UpdateService.new }
    register('services.users.restore') { Users::RestoreService.new }
    register('services.weeks.bench_substitutions') { Weeks::BenchSubstitutionsService.new }
    register('services.weeks.finish') { Weeks::FinishService.new }
    register('services.players.seasons.refresh_selected') { Players::Seasons::RefreshSelectedService.new }
    register('services.games.difficulty_update') { Games::DifficultyUpdateService.new }
    register('services.oraculs.points.update') { Oraculs::Points::UpdateService.new }
    register('services.oraculs.lineups.points.update') { Oraculs::Lineups::Points::UpdateService.new }
    register('services.oracul_leagues.members.update_current_place') {
      OraculLeagues::Members::CurrentPlaceUpdateService.new
    }

    # queries
    register('queries.games') { GamesQuery.new }
    register('queries.cups.pairs') { Cups::PairsQuery.new }
  end
end

Deps = Dry::AutoInject(FantasySports::Container)

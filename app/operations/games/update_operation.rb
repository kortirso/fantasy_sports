# frozen_string_literal: true

module Games
  # after receiving game statistics it's required to update all related information
  class UpdateOperation
    prepend ApplicationService

    POINTS_CALCULATE_SERVICES = {
      'basketball' => ::Games::Players::Points::Calculate::BasketballService,
      'football' => ::Games::Players::Points::Calculate::FootballService
    }.freeze

    def initialize(
      players_seasons_mass_update_job: ::Players::Seasons::MassUpdateJob
    )
      @players_seasons_mass_update_job = players_seasons_mass_update_job
    end

    # game_data must have specific format
    # [
    #   {
    #     points: 123,
    #     players: { '1' => { 'MP' => 90 } }, ... list of home team players, key is shirt_number, value - stats
    #   },
    #   {
    #     points: 124,
    #     players: { '2' => { 'MP' => 45 } }  ... list of visitor team players, key is shirt_number, value - stats
    #   }
    # ]
    def call(game:, game_data:)
      @game = game
      @games_players_update_data = []
      @player_ids = []
      @points_calculate_service = POINTS_CALCULATE_SERVICES[@game.week.season.league.sport_kind].new

      # this data is updated immediately
      ActiveRecord::Base.transaction do
        update_game(game_data)
        update_games_players(game_data)
      end
      # this data can be updated in background
      update_players
    end

    private

    def update_game(game_data)
      return if game_data.dig(0, :points).nil? || game_data.dig(1, :points).nil?

      # TODO: use service for update, modify contract to allow set array of values as points
      # commento: games.points
      @game.update!(points: [game_data.dig(0, :points), game_data.dig(1, :points)])
    end

    def update_games_players(game_data)
      calculate_games_players_points(@game.home_season_team_id, game_data.dig(0, :players))
      calculate_games_players_points(@game.visitor_season_team_id, game_data.dig(1, :players))
      # commento: games_players.points, games_players.statistic
      Games::Player.upsert_all(@games_players_update_data) if @games_players_update_data.any?
    end

    # rubocop: disable Metrics/AbcSize
    def calculate_games_players_points(season_team_id, game_data)
      games_players =
        @game
        .games_players
        .includes(:teams_player)
        .where(teams_player: { seasons_team_id: season_team_id, active: true, shirt_number_string: game_data.keys })

      games_players.each do |games_player|
        statistic = game_data[games_player.teams_player.shirt_number_string].transform_values(&:to_i)

        points = @points_calculate_service.call(position_kind: games_player.position_kind, statistic: statistic).result
        @games_players_update_data.push({
          id: games_player.id,
          game_id: games_player.game_id,
          teams_player_id: games_player.teams_player_id,
          seasons_team_id: games_player.seasons_team_id,
          points: points,
          statistic: statistic
        })

        @player_ids.push(games_player.teams_player.player_id)
      end
    end
    # rubocop: enable Metrics/AbcSize

    def update_players
      @players_seasons_mass_update_job.perform_now(season_id: @game.week.season_id, player_ids: @player_ids.flatten)
    end
  end
end

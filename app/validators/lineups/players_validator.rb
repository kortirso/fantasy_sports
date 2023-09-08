# frozen_string_literal: true

module Lineups
  class PlayersValidator
    CHANGE_ORDERS_TEMPLATE = [1, 2, 3, 4].freeze

    def initialize(sport_kind:)
      sport = Sport.find_by(title: sport_kind)

      @active_players_limit = sport.max_active_players
      @validate_changes = sport.changes
      @validate_captain = sport.captain
    end

    def call(lineup:, lineups_players_params:)
      @lineups_players_uuids = lineup.lineups_players.order(uuid: :asc).pluck(:uuid)

      initialize_counters
      collect_players_data(lineups_players_params)

      validate_lineup_player_ids
      validate_active_players_count if @errors.empty?
      validate_change_orders if @validate_changes && @errors.empty?
      validate_captains_count if @validate_captain && @errors.empty?

      @errors
    end

    private

    def initialize_counters
      @errors                 = []
      @players_uuids          = []
      @active_players         = 0
      @positive_change_orders = []
      @captains               = []
    end

    def collect_players_data(lineups_players_params)
      lineups_players_params.each do |params_hash|
        @players_uuids.push(params_hash[:uuid])
        @active_players += 1 if params_hash[:change_order].zero?
        @captains.push(params_hash[:status]) if params_hash[:status] && params_hash[:status] != Lineups::Player::REGULAR
        if @validate_changes && params_hash[:change_order].positive?
          @positive_change_orders.push(params_hash[:change_order])
        end
      end
    end

    def validate_lineup_player_ids
      return if @players_uuids.sort == @lineups_players_uuids

      @errors.push('Invalid players list')
    end

    def validate_active_players_count
      return if @active_players == @active_players_limit

      @errors.push('Invalid amount of active players')
    end

    def validate_change_orders
      return if @positive_change_orders.sort == CHANGE_ORDERS_TEMPLATE

      @errors.push('Invalid changing order')
    end

    def validate_captains_count
      return if @captains.sort == [Lineups::Player::ASSISTANT, Lineups::Player::CAPTAIN]

      @errors.push('Invalid captains count')
    end
  end
end

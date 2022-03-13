# frozen_string_literal: true

module Lineups
  class PlayersValidator < ApplicationValidator
    CHANGE_ORDERS_TEMPLATE = [1, 2, 3, 4].freeze

    def initialize(sport_kind:)
      settings = Sports.sport(sport_kind)

      @active_players_limit = settings['max_active_players']
      @validate_changes = settings['max_players'] != settings['max_active_players']
    end

    def call(lineup:, lineups_players_params:)
      @lineups_players_ids = lineup.lineups_players.order(id: :asc).ids

      initialize_counters
      validate_players_data(lineups_players_params)
      validate_active_players_count
      validate_change_orders if @validate_changes

      @errors
    end

    private

    def initialize_counters
      @errors                 = []
      @players_ids            = []
      @active_players         = 0
      @positive_change_orders = []
    end

    def validate_players_data(lineups_players_params)
      lineups_players_params.each do |params_hash|
        @players_ids.push(params_hash['id'])
        @active_players += 1 if params_hash['active'] == true
        if @validate_changes && params_hash['change_order'].positive?
          @positive_change_orders.push(params_hash['change_order'])
        end
      end
    end

    def validate_lineup_player_ids
      return if @players_ids.sort == @lineups_players_ids

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
  end
end

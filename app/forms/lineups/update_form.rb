# frozen_string_literal: true

module Lineups
  class UpdateForm
    include Deps[validator: 'validators.lineups.update']

    def call(lineup:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      error = params[:active_chips] ? validate_chips(lineup, params[:active_chips]) : nil
      return { errors: [error] } if error.present?

      ActiveRecord::Base.transaction do
        update_available_chips(lineup, params[:active_chips]) if params[:active_chips]
        update_lineup(lineup, params)
      end

      { result: lineup.reload }
    end

    private

    # rubocop: disable Metrics/AbcSize
    def validate_chips(lineup, chips)
      return if lineup.active_chips.sort == chips.sort

      max_chips_per_week = Sport.find_by(title: lineup.fantasy_team.sport_kind).max_chips_per_week
      return I18n.t('services.lineups.update.too_many_chips') if chips.size > max_chips_per_week

      return I18n.t('services.lineups.update.wildcard_active') if lineup.active_chips.include?(Chipable::WILDCARD)

      # if added chips can not be added
      not_enough_chips = (chips - lineup.active_chips).any? { |chip| lineup.fantasy_team.available_chips[chip].zero? }
      I18n.t('services.lineups.update.not_enough_chips') if not_enough_chips
    end
    # rubocop: enable Metrics/AbcSize

    def update_available_chips(lineup, chips)
      added_chips = chips - lineup.active_chips
      return change_available_chips(lineup, added_chips, -1) if added_chips.any?

      removed_chips = lineup.active_chips - chips
      change_available_chips(lineup, removed_chips, 1) if removed_chips.any?
    end

    def change_available_chips(lineup, chips, modifier)
      chips.each { |chip| lineup.fantasy_team.available_chips[chip] += modifier }
      # commento: fantasy_teams.available_chips
      lineup.fantasy_team.save!
    end

    def update_lineup(lineup, params)
      if params[:active_chips].include?(Chipable::WILDCARD)
        params[:transfers_limited] = false
        params[:penalty_points] = 0
      end
      # commento: lineups.active_chips, lineups.transfers_limited, lineups.penalty_points
      lineup.update!(params)
    end
  end
end

# frozen_string_literal: true

module Lineups
  class UpdateService
    prepend ApplicationService
    include Validateable

    def initialize(lineup_validator: Lineups::UpdateValidator)
      @lineup_validator = lineup_validator
    end

    def call(lineup:, params:)
      @lineup = lineup
      return if validate_with(@lineup_validator, params) && failure?
      return if params[:active_chips] && validate_chips(params[:active_chips]) && failure?

      ActiveRecord::Base.transaction do
        update_available_chips(params[:active_chips]) if params[:active_chips]
        update_lineup(params)
      end
    end

    private

    def validate_chips(chips)
      return if @lineup.active_chips.sort == chips.sort
      return if chips.size <= Sport.find_by(title: fantasy_team.sport_kind).max_chips_per_week

      fail!(I18n.t('services.lineups.update.too_many_chips'))
    end

    def update_available_chips(chips)
      added_chips = chips - @lineup.active_chips
      # if added chips can not be added
      if added_chips.any? { |chip| fantasy_team.available_chips[chip].zero? }
        return fail!(I18n.t('services.lineups.update.not_enough_chips'))
      end
      return change_available_chips(added_chips, -1) if added_chips.any?

      removed_chips = @lineup.active_chips - chips
      change_available_chips(removed_chips, 1) if removed_chips.any?
    end

    def update_lineup(params)
      @lineup.update!(params) unless failure?
    end

    def change_available_chips(chips, modifier)
      chips.each { |chip| fantasy_team.available_chips[chip] += modifier }
      fantasy_team.save!
    end

    def fantasy_team
      @fantasy_team ||= @lineup.fantasy_team
    end
  end
end

# frozen_string_literal: true

module Seasons
  class CreateService
    prepend ApplicationService
    include Validateable

    def initialize(season_validator: SeasonValidator)
      @season_validator = season_validator
    end

    def call(params: {})
      return if find_league(params[:league_id]) && failure?
      return if validate_with(@season_validator, params) && failure?

      ActiveRecord::Base.transaction do
        @league.seasons.active.update!(active: false) if params[:active]
        @league.seasons.create!(params)
      end
    end

    private

    def find_league(league_id)
      @league = League.find_by(id: league_id)
      return if @league

      fail!(I18n.t('services.seasons.create.league_does_not_exist'))
    end
  end
end

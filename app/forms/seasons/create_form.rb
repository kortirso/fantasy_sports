# frozen_string_literal: true

module Seasons
  class CreateForm
    include Deps[validator: 'validators.season']

    def call(params:)
      league = League.find_by(id: params[:league_id])
      return { errors: [I18n.t('services.seasons.create.league_does_not_exist')] } if league.nil?

      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = ActiveRecord::Base.transaction do
        # commento: seasons.name, seasons.active
        league.seasons.active.update!(active: false) if params[:active]
        league.seasons.create!(params)
      end

      { result: result }
    end
  end
end

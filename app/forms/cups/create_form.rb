# frozen_string_literal: true

module Cups
  class CreateForm
    include Deps[validator: 'validators.cup']

    def call(params:)
      league = League.find_by(id: params[:league_id])
      return { errors: [I18n.t('services.cups.create.league_does_not_exist')] } if league.nil?

      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      result = league.cups.create!(params)

      { result: result }
    end
  end
end

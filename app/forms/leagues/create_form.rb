# frozen_string_literal: true

module Leagues
  class CreateForm
    include Deps[validator: 'validators.league']

    def call(params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      # commento: leagues.name
      { result: League.create!(params) }
    end
  end
end

# frozen_string_literal: true

module Leagues
  class CreateForm
    prepend ApplicationService
    include Validateable

    def call(params:)
      return if validate_with(validator, params) && failure?

      League.create!(params)
    end

    private

    def validator = FantasySports::Container['validators.league']
  end
end

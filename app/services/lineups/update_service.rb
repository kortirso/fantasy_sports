# frozen_string_literal: true

module Lineups
  class UpdateService
    prepend ApplicationService

    def initialize(lineup_validator: Lineups::UpdateValidator)
      @lineup_validator = lineup_validator
    end

    def call(lineup:, params:)
      return if validate_with(@lineup_validator, params) && failure?

      lineup.update!(params)
    end
  end
end

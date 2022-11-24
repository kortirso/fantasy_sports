# frozen_string_literal: true

module Games
  class UpdateService
    prepend ApplicationService
    include Validateable

    def initialize(game_validator: Games::UpdateValidator)
      @game_validator = game_validator
    end

    def call(game:, params:)
      return if validate_with(@game_validator, params) && failure?

      game.update!(params)
    end
  end
end

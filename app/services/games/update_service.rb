# frozen_string_literal: true

module Games
  class UpdateService
    prepend ApplicationService
    include Validateable

    def call(game:, params:)
      return if validate_with(validator, params) && failure?

      game.update!(params)
    end

    private

    def validator = FantasySports::Container['validators.games.update']
  end
end

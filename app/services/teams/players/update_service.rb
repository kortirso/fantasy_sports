# frozen_string_literal: true

module Teams
  module Players
    class UpdateService
      prepend ApplicationService

      def call(teams_player:, params:)
        teams_player.update!(params)
      end
    end
  end
end

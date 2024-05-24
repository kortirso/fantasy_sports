# frozen_string_literal: true

module Users
  module Sessions
    class RemoveExpiredJob < ApplicationJob
      queue_as :default

      def perform
        Users::Session
          .where(created_at: ...JwtEncoder::EXPIRATION_SECONDS.seconds.ago)
          .destroy_all
      end
    end
  end
end

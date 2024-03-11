# frozen_string_literal: true

module Api
  module V1
    module Users
      class MeController < Api::V1Controller
        skip_before_action :check_email_confirmation, only: %i[index]
        skip_before_action :check_email_ban, only: %i[index]

        SERIALIZER_FIELDS = %w[confirmed banned].freeze

        def index
          render json: {
            user: UserSerializer.new(current_user, params: { fields: SERIALIZER_FIELDS }).serializable_hash
          }, status: :ok
        end
      end
    end
  end
end

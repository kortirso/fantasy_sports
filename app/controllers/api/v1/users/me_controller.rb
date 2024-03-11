# frozen_string_literal: true

module Api
  module V1
    module Users
      class MeController < Api::V1Controller
        skip_before_action :check_email_confirmation, only: %i[index]
        skip_before_action :check_email_ban, only: %i[index]

        def index
          render json: {
            user: Api::V1::UserSerializer.new(current_user).serializable_hash
          }, status: :ok
        end
      end
    end
  end
end

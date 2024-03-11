# frozen_string_literal: true

module Api
  module V1
    module Users
      class AccessTokensController < Api::V1Controller
        skip_before_action :authenticate, only: %i[create]
        skip_before_action :check_email_confirmation, only: %i[create]
        skip_before_action :check_email_ban, only: %i[create]

        before_action :find_user, only: %i[create]
        before_action :authenticate_user, only: %i[create]

        SERIALIZER_FIELDS = %w[confirmed banned access_token].freeze

        def create
          render json: {
            user: UserSerializer.new(@user, params: { fields: SERIALIZER_FIELDS }).serializable_hash
          }, status: :created
        end

        private

        def find_user
          @user = User.not_banned.find_by!(email: user_params[:email]&.strip&.downcase)
        end

        def authenticate_user
          return if @user.authenticate(user_params[:password])

          failed_sign_in
        end

        def failed_sign_in
          render json: { errors: [t('controllers.users.sessions.invalid')] }, status: :bad_request
        end

        def user_params
          params.require(:user).permit(:email, :password)
        end
      end
    end
  end
end

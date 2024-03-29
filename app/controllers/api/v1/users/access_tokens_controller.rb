# frozen_string_literal: true

module Api
  module V1
    module Users
      class AccessTokensController < Api::V1Controller
        skip_before_action :authenticate, only: %i[create]
        skip_before_action :check_email_ban, only: %i[create]

        before_action :find_user, only: %i[create]
        before_action :authenticate_user, only: %i[create]

        SERIALIZER_FIELDS = %w[confirmed banned access_token].freeze

        def create
          render json: {
            user: UserSerializer.new(
              @user, params: serializer_fields(UserSerializer, SERIALIZER_FIELDS)
            ).serializable_hash
          }, status: :created
        end

        private

        def find_user
          @user = find_by_email || find_by_username
          page_not_found unless @user
        end

        def find_by_email
          User.not_banned.find_by(email: user_params[:login]&.strip&.downcase)
        end

        def find_by_username
          User.not_banned.find_by(username: user_params[:login])
        end

        def authenticate_user
          return if @user.authenticate(user_params[:password])

          failed_sign_in
        end

        def failed_sign_in
          render json: { errors: [t('controllers.users.sessions.invalid')] }, status: :unprocessable_entity
        end

        def user_params
          params.require(:user).permit(:login, :password)
        end
      end
    end
  end
end

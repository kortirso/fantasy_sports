# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1Controller
      include Deps[create_form: 'forms.users.create']

      SERIALIZER_FIELDS = %w[confirmed banned access_token].freeze

      skip_before_action :authenticate, only: %i[create]
      skip_before_action :check_email_confirmation, only: %i[create destroy]
      skip_before_action :check_email_ban, only: %i[create destroy]

      def create
        case create_form.call(params: user_params.to_h.symbolize_keys)
        in { errors: errors } then render json: { errors: errors }, status: :bad_request
        in { result: result }
          render json: {
            user: UserSerializer.new(
              result, params: serializer_fields(UserSerializer, SERIALIZER_FIELDS)
            ).serializable_hash
          }, status: :created
        end
      end

      def destroy
        ::Users::DestroyJob.perform_later(id: Current.user.id)
        render json: { result: 'ok' }, status: :ok
      end

      private

      def user_params
        params_hash = params.require(:user).permit(:email, :password, :password_confirmation)
        params_hash[:email] = params_hash[:email].strip.downcase
        params_hash
      end
    end
  end
end

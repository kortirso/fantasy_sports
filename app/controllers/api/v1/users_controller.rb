# frozen_string_literal: true

module Api
  module V1
    class UsersController < Api::V1::BaseController
      include Deps[
        generate_token: 'services.auth.generate_token',
        create_form: 'forms.users.create'
      ]

      skip_before_action :authenticate, only: %i[create]
      skip_before_action :check_email_confirmation, only: %i[create]
      skip_before_action :check_email_ban, only: %i[create]

      def create
        case create_form.call(params: user_params.to_h.symbolize_keys)
        in { errors: errors } then render json: { errors: errors }, status: :bad_request
        in { result: result }
          render json: { access_token: generate_token.call(user: result)[:result] }, status: :created
        end
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

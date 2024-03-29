# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    include Deps[
      generate_token: 'services.auth.generate_token',
      create_form: 'forms.users.create'
    ]

    skip_before_action :authenticate
    before_action :check_recaptcha, only: %i[create]

    def new
      @user = User.new
    end

    def new_username
      @user = User.new
    end

    def create
      # commento: users.email, users.username, users.password, users.password_confirmation
      case create_form.call(params: user_params.to_h.symbolize_keys)
      in { errors: errors } then failed_create_response(errors)
      in { result: result } then success_create_response(result)
      end
    end

    def confirm; end

    private

    def check_recaptcha
      failed_create_response([t('controllers.users.registrations.failed_recaptcha')]) unless verify_recaptcha
    end

    def success_create_response(user)
      cookies[:fantasy_sports_token] = {
        value: generate_token.call(user: user)[:result],
        expires: 1.week.from_now
      }
      redirect_to after_registration_path, notice: t('controllers.users.registrations.success_create')
    end

    def failed_create_response(errors)
      @user = User.new(user_params)
      redirect_to users_sign_up_path, alert: errors
    end

    def after_registration_path
      draft_players_path
    end

    def user_params
      params_hash = params.require(:user).permit(:email, :username, :password, :password_confirmation)
      params_hash[:email] = params_hash[:email].strip.downcase if params_hash[:email].present?
      params_hash
    end
  end
end

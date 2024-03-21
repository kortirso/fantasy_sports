# frozen_string_literal: true

module Users
  class RecoveryController < ApplicationController
    include Deps[update_password_form: 'forms.users.update_password']

    skip_before_action :authenticate
    before_action :find_user
    before_action :check_recovery_token

    def new; end

    def create
      # commento: users.password, users.password_confirmation
      case update_password_form.call(user: @user, params: user_params)
      in { errors: errors } then failed_recovery(errors)
      else success_recovery_response
      end
    end

    private

    def success_recovery_response
      @user.regenerate_restore_token
      redirect_to users_login_path, notice: t('controllers.users.recovery.success')
    end

    def find_user
      @user = User.not_banned.find_by(email: params[:email]&.strip&.downcase)
      return if @user.present?

      failed_recovery
    end

    def check_recovery_token
      return if @user.restore_token == params[:restore_token]

      failed_recovery
    end

    def failed_recovery(alert=t('controllers.users.recovery.invalid'))
      redirect_to users_recovery_path(email: params[:email], restore_token: params[:restore_token]), alert: alert
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  end
end

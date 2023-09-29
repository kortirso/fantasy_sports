# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate
    skip_before_action :check_email_confirmation

    def new
      @user = User.new
    end

    def create
      form = Users::CreateForm.call(params: user_params.to_h.symbolize_keys)
      form.success? ? success_create_response(form.result) : failed_create_response(form.errors)
    end

    def confirm; end

    private

    def success_create_response(user)
      session[:fantasy_sports_token] = ::Auth::GenerateToken.call(user: user).result
      redirect_to after_registration_path, notice: t('controllers.users.registrations.success_create')
    end

    def failed_create_response(errors)
      @user = User.new(user_params)
      render :new, alert: errors
    end

    def after_registration_path
      users_confirm_path
    end

    def user_params
      params_hash = params.require(:user).permit(:email, :password, :password_confirmation)
      params_hash[:email].downcase!
      params_hash
    end
  end
end

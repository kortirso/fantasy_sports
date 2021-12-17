# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    skip_before_action :authenticate

    def new
      @user = User.new
    end

    def create
      service_call = Users::CreateService.call(params: user_params)
      service_call.success? ? success_create_response(service_call) : failed_create_response(service_call)
    end

    private

    def success_create_response(service_call)
      session[:fantasy_sports_user_id] = service_call.result.id
      redirect_to after_registration_path, notice: t('controllers.users.registrations.success_create')
    end

    def failed_create_response(service_call)
      @user = User.new(user_params)
      render :new, alert: service_call.errors
    end

    def after_registration_path
      home_path
    end

    def user_params
      params_hash = params.require(:user).permit(:email, :password, :password_confirmation)
      params_hash[:email].downcase!
      params_hash
    end
  end
end

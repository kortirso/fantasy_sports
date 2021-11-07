# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    def new
      @user = User.new
    end

    def create
      service_call = Users::CreateService.call(params: user_params)
      if service_call.success?
        session[:fantasy_sports_user_id] = service_call.result.id
        flash[:notice] = 'You are signed up'
        redirect_to after_registration_path
      else
        @user = User.new(user_params)
        flash[:alert] = service_call.errors
        render :new
      end
    end

    private

    def after_registration_path
      root_path
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
  end
end

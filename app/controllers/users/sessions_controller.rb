# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    before_action :find_user, only: %i[create]
    before_action :authenticate_user, only: %i[create]

    def new; end

    def create
      session[:gamify_user_id] = @user.id
      flash[:notice] = 'You are logged in'
      redirect_to after_login_path
    end

    def destroy
      session[:gamify_user_id] = nil
      flash[:notice] = 'You are logged out'
      redirect_to after_logout_path
    end

    private

    def find_user
      @user = User.find_by(email: user_params[:email])
      return if @user.present?

      failed_sign_in
    end

    def authenticate_user
      return if @user.authenticate(user_params[:password])

      failed_sign_in
    end

    def failed_sign_in
      flash[:alert] = 'Invalid credentials'
      render :new
    end

    def after_login_path
      root_path
    end

    def after_logout_path
      root_path
    end

    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end

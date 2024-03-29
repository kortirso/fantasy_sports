# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    include Deps[generate_token: 'services.auth.generate_token']

    skip_before_action :authenticate
    skip_before_action :check_email_ban
    before_action :find_user, only: %i[create]
    before_action :authenticate_user, only: %i[create]

    def new; end

    def create
      cookies[:fantasy_sports_token] = {
        value: generate_token.call(user: @user)[:result],
        expires: 1.week.from_now
      }
      redirect_to after_login_path, notice: t('controllers.users.sessions.success_create')
    end

    def destroy
      # TODO: Here can be destroying token from database
      cookies.delete(:fantasy_sports_token)
      redirect_to after_logout_path, notice: t('controllers.users.sessions.success_destroy')
    end

    private

    def find_user
      @user = find_by_email || find_by_username
      return if @user.present?

      failed_sign_in
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
      redirect_to users_login_path, alert: t('controllers.users.sessions.invalid')
    end

    def after_login_path
      draft_players_path
    end

    def after_logout_path
      root_path
    end

    def user_params
      params.require(:user).permit(:login, :password)
    end
  end
end

# frozen_string_literal: true

module Users
  class RestoreController < ApplicationController
    include Deps[restore_service: 'services.users.restore']

    skip_before_action :authenticate
    before_action :find_user, only: %i[create]
    before_action :validate_restore_limit, only: %i[create]

    def new; end

    def create
      restore_service.call(user: @user)
      redirect_to users_restore_path, notice: t('controllers.users.restore.success')
    end

    private

    def find_user
      @user = User.confirmed.not_banned.find_by(email: params[:email]&.strip&.downcase)
      return if @user.present?

      redirect_to users_restore_path, alert: t('controllers.users.restore.invalid')
    end

    def validate_restore_limit
      return if @user.restoreable?

      redirect_to users_restore_path, alert: t('controllers.users.restore.unavailable')
    end
  end
end

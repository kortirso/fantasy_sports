# frozen_string_literal: true

module Users
  class ConfirmationsController < ApplicationController
    include Deps[update_service: 'services.persisters.users.update']

    skip_before_action :authenticate
    before_action :find_user
    before_action :check_confirmation_token

    def complete
      # commento: users.confirmation_token, users.confirmed_at
      update_service.call(user: @user, params: { confirmation_token: nil, confirmed_at: DateTime.now })
      redirect_to home_path, notice: t('controllers.users.confirmations.success')
    end

    private

    def find_user
      @user = User.not_confirmed.find_by(email: params[:email]&.strip&.downcase)
      return if @user.present?

      failed_complete_confirmation
    end

    def check_confirmation_token
      return if @user.confirmation_token == params[:confirmation_token]

      failed_complete_confirmation
    end

    def failed_complete_confirmation
      render :failed_complete, alert: t('controllers.users.confirmations.failure')
    end
  end
end

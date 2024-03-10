# frozen_string_literal: true

module Confirmation
  extend ActiveSupport::Concern

  private

  def check_email_confirmation
    return if Current.user.nil? || Current.user.confirmed?

    confirmation_error
  end

  def check_email_ban
    return if Current.user.nil? || !Current.user.banned?

    ban_error
  end

  def confirmation_error
    redirect_to users_confirm_path, alert: t('controllers.confirmation.permission')
  end

  def ban_error
    redirect_to root_path, alert: t('controllers.confirmation.ban')
  end
end

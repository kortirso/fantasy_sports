# frozen_string_literal: true

module Confirmation
  extend ActiveSupport::Concern

  private

  def check_email_ban
    return if Current.user.nil? || !Current.user.banned?

    ban_error
  end

  def ban_error
    redirect_to root_path, alert: t('controllers.confirmation.ban')
  end
end

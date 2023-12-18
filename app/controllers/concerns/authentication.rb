# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  private

  def current_user
    return unless cookies[:fantasy_sports_token]

    auth_call = FantasySports::Container['services.auth.fetch_session'].call(token: cookies[:fantasy_sports_token])
    return if auth_call[:errors].present?

    Current.user ||= auth_call[:result].user
  end

  def authenticate
    return if Current.user

    authentication_error
  end

  def authentication_error
    redirect_to users_login_path, alert: t('controllers.authentication.permission')
  end
end

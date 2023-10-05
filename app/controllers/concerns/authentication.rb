# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  private

  def current_user
    return unless session[:fantasy_sports_token]

    auth_call = FantasySports::Container['services.auth.fetch_session'].call(token: session[:fantasy_sports_token])
    return if auth_call[:errors].present?

    Current.user ||= auth_call[:result].user
  end

  def authenticate
    return if Current.user

    redirect_to users_login_path, alert: t('controllers.authentication.permission')
  end
end

# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  private

  def current_user
    Current.user ||= User.find_by(id: session[:fantasy_sports_user_id]) if session[:fantasy_sports_user_id]
  end

  def authenticate
    return if Current.user

    flash[:alert] = t('controllers.authentication.permission')
    redirect_to users_login_path
  end
end

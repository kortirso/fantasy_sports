# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authorize_admin

  private

  def authorize_admin
    return if Current.user.admin?

    flash[:alert] = t('controllers.admin.permission')
    redirect_to home_path
  end
end

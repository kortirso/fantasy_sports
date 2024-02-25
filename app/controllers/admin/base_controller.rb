# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authorize_admin

    layout 'admin'

    private

    def authorize_admin
      return if Current.user.admin?

      redirect_to home_path, alert: t('controllers.admin.permission')
    end
  end
end

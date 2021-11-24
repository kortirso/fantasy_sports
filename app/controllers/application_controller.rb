# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  include Authentication
  include Localization

  before_action :authenticate

  private

  def request_fields
    return if params[:fields].blank?

    params[:fields].split(',')
  end
end

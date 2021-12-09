# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  prepend_view_path Rails.root.join('frontend')

  include Authentication
  include Localization

  authorize :user, through: :current_user

  before_action :authenticate

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found

  def page_not_found
    message = t('controllers.application.page_not_found')
    return json_response_with_error(message, 404) if request.format.json?

    html_response_with_error(message)
  end

  private

  def html_response_with_error(message)
    @message = message
    render template: 'shared/404', status: :not_found, formats: [:html]
  end

  def json_response_with_error(message, status=400)
    render json: { error: message }, status: status
  end

  def request_fields
    return if params[:fields].blank?

    params[:fields].split(',')
  end
end

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  append_view_path Rails.root.join('app/views/controllers')

  include Authentication
  include Confirmation
  include Localization
  include Parameterable
  include Watchable

  # TODO: remember to skip redundant before actions in
  # Api::Frontend::BaseController, Admin::BaseController, Api::V1::BaseController
  before_action :authenticate, except: %i[page_not_found]
  before_action :check_email_ban, except: %i[page_not_found]

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found
  rescue_from InvalidInputParamsError, with: :invalid_params

  # rubocop: disable Lint/UselessMethodDefinition
  # https://github.com/dry-rb/dry-auto_inject/issues/91
  def initialize = super
  # rubocop: enable Lint/UselessMethodDefinition

  def page_not_found
    message = t('controllers.application.page_not_found')
    return json_response_with_errors([message], 404) if request.format.json?

    html_response_with_error(message)
  end

  private

  def html_response_with_error(message)
    @message = message
    render template: 'shared/404', status: :not_found, formats: [:html]
  end

  def json_response_with_errors(messages, status=400)
    render json: { errors: messages }, status: status
  end

  def request_fields
    return if params[:fields].blank?

    params[:fields].split(',')
  end
end

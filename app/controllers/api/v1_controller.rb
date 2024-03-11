# frozen_string_literal: true

module Api
  class V1Controller < ApplicationController
    protect_from_forgery with: :null_session

    private

    def current_user
      return unless params[:access_token]

      auth_call = FantasySports::Container['services.auth.fetch_session'].call(token: params[:access_token])
      return if auth_call[:errors].present?

      Current.user ||= auth_call[:result].user
    end

    def serializer_fields(serializer_class, default_include_fields)
      @serializer_attributes = serializer_class.attributes_to_serialize.keys.map(&:to_s)
      return {} if response_include_fields.any? && response_exclude_fields.any?
      return { include_fields: response_include_fields } if response_include_fields.any?
      return { exclude_fields: response_exclude_fields } if response_exclude_fields.any?

      { include_fields: default_include_fields }
    end

    def response_include_fields
      @response_include_fields ||= params[:response_include_fields]&.split(',').to_a & @serializer_attributes
    end

    def response_exclude_fields
      @response_exclude_fields ||= params[:response_exclude_fields]&.split(',').to_a & @serializer_attributes
    end

    def page_not_found
      render json: { errors: ['Not found'] }, status: :not_found
    end

    def authentication_error
      render json: { errors: [t('controllers.authentication.permission')] }, status: :unauthorized
    end

    def confirmation_error
      render json: { errors: [t('controllers.confirmation.permission')] }, status: :unauthorized
    end

    def ban_error
      render json: { errors: [t('controllers.confirmation.ban')] }, status: :unauthorized
    end
  end
end

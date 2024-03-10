# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session

      private

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
end

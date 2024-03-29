# frozen_string_literal: true

module Api
  module Frontend
    class FeedbacksController < ApplicationController
      include Deps[create_form: 'forms.feedbacks.create']

      def create
        # commento: feedbacks.title, feedbacks.description
        case create_form.call(user: Current.user, params: feedback_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result } then render json: { result: result }, status: :ok
        end
      end

      private

      def feedback_params
        params.require(:feedback).permit(:title, :description)
      end
    end
  end
end

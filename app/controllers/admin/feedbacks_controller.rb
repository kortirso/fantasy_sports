# frozen_string_literal: true

module Admin
  class FeedbacksController < AdminController
    before_action :find_feedbacks, only: %i[index]

    def index; end

    private

    def find_feedbacks
      @feedbacks = Feedback.all
    end
  end
end

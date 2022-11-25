# frozen_string_literal: true

module Profile
  class AchievementsController < ApplicationController
    before_action :find_achievements, only: %i[index]
    after_action :mark_unread_achievements_as_read, only: %i[index]

    def index; end

    private

    def find_achievements
      @achievements = Current.user.achievements.order(updated_at: :desc)
    end

    def mark_unread_achievements_as_read
      Current.user.achievements.unread.update_all(notified: true)
    end
  end
end

# frozen_string_literal: true

class AchievementSerializer < ApplicationSerializer
  set_id nil

  attributes :title, :description, :points, :updated_at
end

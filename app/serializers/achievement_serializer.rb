# frozen_string_literal: true

class AchievementSerializer < ApplicationSerializer
  set_id nil

  attributes :title, :description, :points

  attribute :updated_at do |object|
    object.updated_at.strftime('%d/%m/%Y')
  end
end

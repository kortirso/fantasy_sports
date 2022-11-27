# frozen_string_literal: true

module Achievementable
  extend ActiveSupport::Concern

  included do
    has_many :users_achievements, class_name: 'Users::Achievement', dependent: :destroy
    has_many :achievements, through: :users_achievements
  end

  def award(achievement:)
    object = users_achievements.find_or_initialize_by(achievement_id: achievement.id)
    return if object.rank.to_i > achievement.rank.to_i

    object.update!(
      {
        rank: achievement.rank,
        points: object.points.to_i + achievement.points,
        title: achievement.title,
        description: achievement.description
      }.compact
    )
  end

  def awarded?(achievement:)
    users_achievements.find_by({ achievement_id: achievement.id, rank: achievement.rank }.compact)
  end
end

# frozen_string_literal: true

module Achievementable
  extend ActiveSupport::Concern

  included do
    has_many :achievements, dependent: :destroy
  end

  def award(achievement:, rank: nil, points: nil)
    object = achievement.find_or_initialize_by(user_id: id)
    object.update!({ rank: rank, points: points }.compact) if object.rank.to_i <= rank.to_i
  end

  def awarded?(achievement:, rank: nil)
    achievements.find_by({ type: achievement.to_s, user_id: id, rank: rank }.compact)
  end
end

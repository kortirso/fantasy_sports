# frozen_string_literal: true

class Achievement < ApplicationRecord
  include Glory
  include Uuidable

  belongs_to :achievement_group

  has_many :users_achievements, class_name: 'Users::Achievement', dependent: :destroy
  has_many :users, through: :users_achievements

  award_for :lineup_points do |achievements, lineup|
    user = lineup.fantasy_team.user
    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && lineup.points >= (achievement.rank * 10)
        user.award(achievement: achievement)
      end
    end
  end

  award_for :fantasy_team_create do |achievements, fantasy_team|
    user = fantasy_team.user
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end
end

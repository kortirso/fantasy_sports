# frozen_string_literal: true

class Achievement < Kudos::Achievement
  BASKETBALL_LINEUP_POINTS = {
    1 => 100,
    2 => 250,
    3 => 500,
    4 => 750,
    5 => 1000
  }.freeze

  BASKETBALL_TOP_LINEUP_INDEX = {
    1 => 1000,
    2 => 100,
    3 => 10,
    4 => 1
  }.freeze

  award_for :basketball_lineup_points do |achievements, points, user|
    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && points >= BASKETBALL_LINEUP_POINTS[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :basketball_top_lineup do |achievements, index, user|
    achievements.each do |achievement|
      if !user.awarded?(achievement: achievement) && index <= BASKETBALL_TOP_LINEUP_INDEX[achievement.rank]
        user.award(achievement: achievement)
      end
    end
  end

  award_for :no_one_team_players do |achievements, user|
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end

  award_for :team_of_friends do |achievements, user|
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end

  award_for :team_of_twins do |achievements, user|
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end

  award_for :straight_players do |achievements, user|
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end

  award_for :fantasy_team_create do |achievements, fantasy_team|
    user = fantasy_team.user
    achievement = achievements.first
    user.award(achievement: achievement) unless user.awarded?(achievement: achievement)
  end
end

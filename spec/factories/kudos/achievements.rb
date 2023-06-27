# frozen_string_literal: true

FactoryBot.define do
  factory :kudos_achievement, class: 'Kudos::Achievement' do
    award_name { 'fantasy_team_create' }
    points { 5 }
    kudos_achievement_group
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    award_name { 'fantasy_team_create' }
    points { 5 }
  end
end

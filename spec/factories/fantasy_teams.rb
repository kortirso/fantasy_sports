# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_team do
    name { 'Bears United' }
    sport_kind { Sportable::FOOTBALL }
    user
    season

    trait :completed do
      completed { true }
    end
  end
end

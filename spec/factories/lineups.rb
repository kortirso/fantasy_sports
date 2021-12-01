# frozen_string_literal: true

FactoryBot.define do
  factory :lineup do
    association :fantasy_team
    association :week
  end
end

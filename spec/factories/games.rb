# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    association :week
    association :home_team, factory: :team
    association :visitor_team, factory: :team
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :transfer do
    association :lineup
    association :teams_player

    trait :in do
      direction { 'in' }
    end

    trait :out do
      direction { 'out' }
    end
  end
end

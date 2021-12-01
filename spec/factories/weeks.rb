# frozen_string_literal: true

FactoryBot.define do
  factory :week do
    position { 1 }
    association :season
  end
end

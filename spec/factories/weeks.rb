# frozen_string_literal: true

FactoryBot.define do
  factory :week do
    position { 1 }
    deadline_at { DateTime.now }
    season
  end
end

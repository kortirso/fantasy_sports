# frozen_string_literal: true

FactoryBot.define do
  factory :injury do
    reason { { en: 'Head/Face Injury', ru: 'Травма головы' } }
    return_at { DateTime.now }
    status { 75 }
    players_season
  end
end

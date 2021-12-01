# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_league do
    name { 'Fantasy League #1' }
    association :leagueable, factory: :season
    association :season
  end
end

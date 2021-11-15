# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_league do
    name { 'Fantasy League #1' }
    association :leagueable, factory: :leagues_season
    association :leagues_season
  end
end

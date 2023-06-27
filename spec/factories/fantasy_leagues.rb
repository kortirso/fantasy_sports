# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_league do
    name { 'Fantasy League #1' }
    leagueable factory: %i[season]
    season
  end
end

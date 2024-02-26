# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_cup do
    name { 'Cup' }
    fantasy_league
  end
end

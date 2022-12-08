# frozen_string_literal: true

FactoryBot.define do
  factory :cup do
    name { 'Cup' }
    association :fantasy_league
  end
end

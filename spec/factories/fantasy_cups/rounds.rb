# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_cups_round, class: 'FantasyCups::Round' do
    name { '1/2' }
    position { 2 }
    fantasy_cup
    week
  end
end

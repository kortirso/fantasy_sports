# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_cups_pair, class: 'FantasyCups::Pair' do
    fantasy_cups_round
    home_lineup factory: %i[lineup]
    visitor_lineup factory: %i[lineup]
  end
end

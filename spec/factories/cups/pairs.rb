# frozen_string_literal: true

FactoryBot.define do
  factory :cups_pair, class: 'Cups::Pair' do
    cups_round
    home_lineup factory: %i[lineup]
    visitor_lineup factory: %i[lineup]
  end
end

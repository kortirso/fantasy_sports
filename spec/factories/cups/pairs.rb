# frozen_string_literal: true

FactoryBot.define do
  factory :cups_pair, class: 'Cups::Pair' do
    association :cups_round
    association :home_lineup, factory: :lineup
    association :visitor_lineup, factory: :lineup
  end
end

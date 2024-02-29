# frozen_string_literal: true

FactoryBot.define do
  factory :cups_pair, class: 'Cups::Pair' do
    home_name { { en: 'Copenhagen', ru: 'Копенгаген' } }
    visitor_name { { en: 'Manchester City', ru: 'Манчестер Сити' } }
    start_at { DateTime.new(2024, 2, 13, 20, 0, 0) }
    cups_round
  end
end

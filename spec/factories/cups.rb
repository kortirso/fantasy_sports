# frozen_string_literal: true

FactoryBot.define do
  factory :cup do
    name { { en: 'Playoff Champions League 2023/2024', ru: 'Плейофф Лиги чемпионов 2023/2024' } }
    active { true }
    league
  end
end

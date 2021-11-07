# frozen_string_literal: true

FactoryBot.define do
  factory :sports_position, class: 'Sports::Position' do
    name { { en: 'Forward', ru: 'Нападающий' } }
    total_amount { 3 }
    min_game_amount { 1 }
    max_game_amount { 3 }
    association :sport
  end
end

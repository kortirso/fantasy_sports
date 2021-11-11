# frozen_string_literal: true

FactoryBot.define do
  factory :player do
    name { { en: 'Akinfeev Igor', ru: 'Акинфеев Игорь' } }
    association :sports_position
  end
end

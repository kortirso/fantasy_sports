# frozen_string_literal: true

FactoryBot.define do
  factory :oracul_place do
    name { { en: 'FA Cup', ru: 'Кубок Лиги' } }
    placeable factory: %i[season]
    active { true }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :cup do
    name { { en: 'Stanley cup', ru: 'Кубок Стенли' } }
    active { true }
    league
  end
end

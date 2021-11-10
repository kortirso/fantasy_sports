# frozen_string_literal: true

FactoryBot.define do
  factory :team do
    name { { en: 'Spartak Moscow', ru: 'Спартак (Москва)' } }
  end
end

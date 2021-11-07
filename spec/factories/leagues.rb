# frozen_string_literal: true

FactoryBot.define do
  factory :league do
    name { { en: 'Football', ru: 'Футбол' } }
    association :sport
  end
end

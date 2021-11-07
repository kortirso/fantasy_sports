# frozen_string_literal: true

FactoryBot.define do
  factory :sport do
    name { { en: 'Football', ru: 'Футбол' } }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :league do
    name { { en: 'Football', ru: 'Футбол' } }
    sport_kind { Sportable::FOOTBALL }
    slug { 'epl' }
  end
end

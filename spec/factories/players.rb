# frozen_string_literal: true

FactoryBot.define do
  factory :player do
    name { { en: 'Akinfeev Igor', ru: 'Акинфеев Игорь' } }
    position_kind { Positionable::GOALKEEPER }
  end
end

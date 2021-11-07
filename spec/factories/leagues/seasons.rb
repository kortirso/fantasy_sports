# frozen_string_literal: true

FactoryBot.define do
  factory :leagues_season, class: 'Leagues::Season' do
    name { '2021/2022' }
    active { true }
    association :league
  end
end

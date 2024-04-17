# frozen_string_literal: true

FactoryBot.define do
  factory :season do
    name { '2021/2022' }
    status { Season::ACTIVE }
    league
  end
end

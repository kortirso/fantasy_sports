# frozen_string_literal: true

FactoryBot.define do
  factory :cups_round, class: 'Cups::Round' do
    name { '1/2' }
    position { 2 }
    association :cup
    association :week
  end
end
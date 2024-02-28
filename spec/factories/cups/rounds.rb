# frozen_string_literal: true

FactoryBot.define do
  factory :cups_round, class: 'Cups::Round' do
    name { '1/8' }
    position { 1 }
    cup
  end
end

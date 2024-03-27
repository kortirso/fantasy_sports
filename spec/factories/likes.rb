# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    user
    likeable factory: %i[season]
  end
end

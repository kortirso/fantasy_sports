# frozen_string_literal: true

FactoryBot.define do
  factory :banned_email do
    value { 'banned777@gmail.com' }
    reason { 'spam' }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :identity do
    uid { '12345' }
    provider { 'telegram' }
    sequence(:email) { |i| "user#{i}@gmail.com" }
    login { 'login' }
    user
  end
end

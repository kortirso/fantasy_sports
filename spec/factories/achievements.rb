# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    type { 'Achievements::FantasyTeams::Create' }
    association :user
  end
end

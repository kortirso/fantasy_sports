# frozen_string_literal: true

FactoryBot.define do
  factory :users_team, class: 'Users::Team' do
    name { 'Bears United' }
    association :user
  end
end

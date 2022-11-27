# frozen_string_literal: true

FactoryBot.define do
  factory :users_achievement, class: 'Users::Achievement' do
    association :user
    association :achievement
  end
end

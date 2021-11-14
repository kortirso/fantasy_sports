# frozen_string_literal: true

FactoryBot.define do
  factory :games_player, class: 'Games::Player' do
    statistic { {} }
    association :game
    association :teams_player
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :games_player, class: 'Games::Player' do
    statistic { {} }
    position_kind { Positionable::GOALKEEPER }
    association :game
    association :teams_player
  end
end

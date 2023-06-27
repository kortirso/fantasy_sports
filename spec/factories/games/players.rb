# frozen_string_literal: true

FactoryBot.define do
  factory :games_player, class: 'Games::Player' do
    statistic { {} }
    position_kind { Positionable::GOALKEEPER }
    game
    teams_player
    seasons_team
  end
end

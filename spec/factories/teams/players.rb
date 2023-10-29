# frozen_string_literal: true

FactoryBot.define do
  factory :teams_player, class: 'Teams::Player' do
    active { true }
    players_season
    seasons_team
    player
  end
end

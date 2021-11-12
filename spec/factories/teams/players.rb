# frozen_string_literal: true

FactoryBot.define do
  factory :teams_player, class: 'Teams::Player' do
    active { true }
    association :leagues_seasons_team
    association :player
  end
end

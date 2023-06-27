# frozen_string_literal: true

FactoryBot.define do
  factory :lineups_player, class: 'Lineups::Player' do
    lineup
    teams_player
  end
end

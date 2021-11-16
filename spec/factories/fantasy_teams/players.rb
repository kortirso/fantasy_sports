# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_teams_player, class: 'FantasyTeams::Player' do
    association :fantasy_team
    association :teams_player
  end
end

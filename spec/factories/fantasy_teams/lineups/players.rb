# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_teams_lineups_player, class: 'FantasyTeams::Lineups::Player' do
    association :fantasy_teams_lineup
    association :teams_player
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_teams_player, class: 'FantasyTeams::Player' do
    fantasy_team
    teams_player
  end
end

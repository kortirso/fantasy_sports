# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_teams_watch, class: 'FantasyTeams::Watch' do
    fantasy_team
    players_season
  end
end

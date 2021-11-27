# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_teams_lineup, class: 'FantasyTeams::Lineup' do
    association :fantasy_team
    association :week
  end
end

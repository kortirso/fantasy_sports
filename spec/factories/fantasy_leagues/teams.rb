# frozen_string_literal: true

FactoryBot.define do
  factory :fantasy_leagues_team, class: 'FantasyLeagues::Team' do
    fantasy_league
    pointable factory: %i[fantasy_team]
  end
end

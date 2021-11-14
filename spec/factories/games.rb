# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    association :week
    association :home_season_team, factory: :leagues_seasons_team
    association :visitor_season_team, factory: :leagues_seasons_team
  end
end

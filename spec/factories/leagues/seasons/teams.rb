# frozen_string_literal: true

FactoryBot.define do
  factory :leagues_seasons_team, class: 'Leagues::Seasons::Team' do
    association :leagues_season
    association :team
  end
end

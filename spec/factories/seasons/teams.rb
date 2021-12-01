# frozen_string_literal: true

FactoryBot.define do
  factory :seasons_team, class: 'Seasons::Team' do
    association :season
    association :team
  end
end

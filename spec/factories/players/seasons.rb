# frozen_string_literal: true

FactoryBot.define do
  factory :players_season, class: 'Players::Season' do
    points { 0 }
    statistic { {} }
    player
    season
  end
end

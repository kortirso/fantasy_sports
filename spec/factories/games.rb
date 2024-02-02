# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    week
    home_season_team factory: %i[seasons_team]
    visitor_season_team factory: %i[seasons_team]

    callback(:before_create) do |game, context|
      game.season_id = context.week.season_id
    end
  end
end

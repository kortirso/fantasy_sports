# frozen_string_literal: true

module Games
  class CreateContract < ApplicationContract
    config.messages.namespace = :game

    params do
      optional(:source).filled(:string)
      optional(:external_id).filled(:string)
      required(:home_season_team_id).filled(:integer)
      required(:visitor_season_team_id).filled(:integer)
      required(:week_id).filled(:integer)
    end

    rule(:home_season_team_id, :visitor_season_team_id) do
      key(:teams).failure(:the_same) if values[:home_season_team_id] == values[:visitor_season_team_id]
    end
  end
end

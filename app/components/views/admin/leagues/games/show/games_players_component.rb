# frozen_string_literal: true

module Views
  module Admin
    module Leagues
      module Games
        module Show
          class GamesPlayersComponent < ViewComponent::Base
            include ApplicationHelper

            def initialize(game:)
              @game          = game
              @games_players = @game.games_players.includes(teams_player: :player)
              @statistic     = ::Statable::FOOTBALL_STATS

              super()
            end
          end
        end
      end
    end
  end
end

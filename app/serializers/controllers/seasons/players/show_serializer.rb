# frozen_string_literal: true

module Controllers
  module Seasons
    module Players
      class ShowSerializer < Teams::PlayerSerializer
        attribute :games_players do |object|
          games_players =
            object
            .games_players
            .includes(game: :week)
            .where(weeks: { status: [Week::COMING, Week::ACTIVE, Week::FINISHED] })
            .order('weeks.position')
          Games::PlayerSerializer.new(games_players).serializable_hash
        end
      end
    end
  end
end

# frozen_string_literal: true

module Games
  class PlayerSerializer < ApplicationSerializer
    attributes :uuid, :statistic, :points

    attribute :week do |object|
      week = object.game.week
      {
        position: week.position
      }
    end
  end
end

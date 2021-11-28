# frozen_string_literal: true

module Sports
  module Kindable
    extend ActiveSupport::Concern

    GOALKEEPER     = 'goalkeeper'
    DEFENDER       = 'defender'
    MIDFIELDER     = 'midfielder'
    FORWARD        = 'forward'
    CENTER         = 'center'
    POWER_FORWARD  = 'power_forward'
    SMALL_FORWARD  = 'small_forward'
    POINT_GUARD    = 'point_guard'
    SHOOTING_GUARD = 'shooting_guard'

    included do
      enum kind: {
        GOALKEEPER     => 0,
        DEFENDER       => 1,
        MIDFIELDER     => 2,
        FORWARD        => 3,
        CENTER         => 4,
        POWER_FORWARD  => 5,
        SMALL_FORWARD  => 6,
        POINT_GUARD    => 7,
        SHOOTING_GUARD => 8
      }
    end
  end
end

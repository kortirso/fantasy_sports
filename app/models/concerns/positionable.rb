# frozen_string_literal: true

module Positionable
  extend ActiveSupport::Concern

  GOALKEEPER     = 'football_goalkeeper'
  DEFENDER       = 'football_defender'
  MIDFIELDER     = 'football_midfielder'
  FORWARD        = 'football_forward'
  CENTER         = 'basketball_center'
  POWER_FORWARD  = 'basketball_power_forward'
  SMALL_FORWARD  = 'basketball_small_forward'
  POINT_GUARD    = 'basketball_point_guard'
  SHOOTING_GUARD = 'basketball_shooting_guard'
  GOALIE         = 'hockey_goalkeeper'
  DEFENSEMAN     = 'hockey_defender'
  HOCKEY_FORWARD = 'hockey_forward'

  included do
    enum position_kind: {
      GOALKEEPER     => 0,
      DEFENDER       => 1,
      MIDFIELDER     => 2,
      FORWARD        => 3,
      CENTER         => 4,
      POWER_FORWARD  => 5,
      SMALL_FORWARD  => 6,
      POINT_GUARD    => 7,
      SHOOTING_GUARD => 8,
      GOALIE         => 9,
      DEFENSEMAN     => 10,
      HOCKEY_FORWARD => 11
    }
  end
end

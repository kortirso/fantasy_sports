# frozen_string_literal: true

module Sportable
  extend ActiveSupport::Concern

  FOOTBALL = 'football'
  BASKETBALL = 'basketball'
  HOCKEY = 'hockey'
  TENNIS = 'tennis'

  included do
    enum sport_kind: {
      FOOTBALL => 0,
      BASKETBALL => 1,
      HOCKEY => 2,
      TENNIS => 3
    }
  end
end

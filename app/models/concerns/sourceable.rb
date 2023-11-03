# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  INSTAT = 'instat'
  BALLDONTLIE = 'balldontlie'
  SPORTRADAR = 'sportradar'
  SPORTS = 'sports'

  included do
    enum source: {
      INSTAT => 0,
      BALLDONTLIE => 1,
      SPORTRADAR => 2,
      SPORTS => 3
    }
  end
end

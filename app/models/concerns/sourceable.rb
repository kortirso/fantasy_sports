# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  INSTAT = 'instat'
  BALLDONTLIE = 'balldontlie'
  SPORTRADAR = 'sportradar'

  included do
    enum source: {
      INSTAT => 0,
      BALLDONTLIE => 1,
      SPORTRADAR => 2
    }
  end
end

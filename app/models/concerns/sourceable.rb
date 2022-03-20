# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  INSTAT = 'instat'
  BALLDONTLIE = 'balldontlie'

  included do
    enum source: {
      INSTAT      => 0,
      BALLDONTLIE => 1
    }
  end
end

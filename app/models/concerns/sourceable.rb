# frozen_string_literal: true

module Sourceable
  extend ActiveSupport::Concern

  INSTAT = 'instat'

  included do
    enum source: {
      INSTAT => 0
    }
  end
end

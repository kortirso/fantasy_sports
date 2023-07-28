# frozen_string_literal: true

module PageWrappers
  class PageComponent < ApplicationViewComponent
    def initialize(fantasy_team: nil)
      @fantasy_team = fantasy_team

      super()
    end
  end
end

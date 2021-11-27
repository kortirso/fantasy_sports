# frozen_string_literal: true

module PageWrappers
  class PageComponent < ViewComponent::Base
    include ApplicationHelper

    def initialize(fantasy_team: nil)
      @fantasy_team = fantasy_team

      super()
    end
  end
end

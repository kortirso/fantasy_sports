# frozen_string_literal: true

module Views
  module Homes
    module Show
      class SportComponent < ApplicationViewComponent
        def initialize(sport_kind:, leagues:, user:)
          @sport_kind   = sport_kind
          @sport_values = Sports.sport(sport_kind)
          @leagues      = leagues
          @user         = user

          super()
        end
      end
    end
  end
end

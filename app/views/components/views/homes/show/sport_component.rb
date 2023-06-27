# frozen_string_literal: true

module Views
  module Homes
    module Show
      class SportComponent < ApplicationViewComponent
        def initialize(sport_kind:, seasons:, user:)
          @sport_kind   = sport_kind
          @sport_values = Sports.sport(sport_kind)
          @seasons      = seasons
          @user         = user

          super()
        end
      end
    end
  end
end

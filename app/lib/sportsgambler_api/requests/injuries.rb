# frozen_string_literal: true

module SportsgamblerApi
  module Requests
    module Injuries
      def get_injuries(league_name:)
        get(path: "injuries/football/#{league_name}")
      end
    end
  end
end

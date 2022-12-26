# frozen_string_literal: true

module Views
  module Cups
    module Show
      class PairScoreComponent < ApplicationViewComponent
        def initialize(cups_pair:, fantasy_team:, score_detect_service: ::Cups::Pairs::ScoreDetectService)
          @cups_pair = cups_pair
          @fantasy_team = fantasy_team
          @score_detect_service = score_detect_service

          super()
        end

        def pair_result
          @pair_result ||= @score_detect_service.call(cups_pair: @cups_pair, fantasy_team: @fantasy_team).result
        end
      end
    end
  end
end

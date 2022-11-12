# frozen_string_literal: true

module Chipable
  extend ActiveSupport::Concern

  BENCH_BOOST = 'bench_boost' # players from bench adds points to lineup
  TRIPLE_CAPTAIN = 'triple_captain' # captain raises x3 points
  FREE_HIT = 'free_hit' # total team change for a week
  WILDCARD = 'wildcard' # free transfers for a week
end

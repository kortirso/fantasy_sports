# frozen_string_literal: true

module Statable
  extend ActiveSupport::Concern

  MP = 'MP' # minutes played
  GS = 'GS' # goals scored
  A  = 'A' # assists
  CS = 'CS' # clean sheet
  GC = 'GC' # goals conceded
  OG = 'OG' # own goals
  PS = 'PS' # penalties saved
  PM = 'PM' # penalties missed
  YC = 'YC' # yellow cards
  RC = 'RC' # red cards
  S  = 'S' # saves
  B  = 'B' # bonus points
  P  = 'P' # points
  REB = 'REB' # rebounds
  BLK = 'BLK' # blocks
  STL = 'STL' # steals
  TO  = 'TO' # turnovers

  FOOTBALL_STATS = [MP, GS, A, CS, GC, OG, PS, PM, YC, RC, S, B].freeze
  RENDERED_FOOTBALL_STATS = [GS, A, YC, RC, S, B].freeze
  BASKETBALL_STATS = [MP, P, REB, A, BLK, STL, TO].freeze
  RENDERED_BASKETBALL_STATS = [P, REB, A, BLK, STL, TO].freeze

  SPORT_STATS = {
    Sportable::FOOTBALL => FOOTBALL_STATS,
    Sportable::BASKETBALL => BASKETBALL_STATS
  }.freeze

  # rendered stats in game statistics block
  RENDERED_SPORT_STATS = {
    Sportable::FOOTBALL => RENDERED_FOOTBALL_STATS,
    Sportable::BASKETBALL => RENDERED_BASKETBALL_STATS
  }.freeze

  included do
    after_initialize :generate_default_statistic
  end

  private

  def generate_default_statistic
    return if id

    self.statistic = select_default_statistic.index_with(0)
  end

  def select_default_statistic
    SPORT_STATS[
      Sports::Position.find_by(title: position_kind).sport
    ] || []
  end
end

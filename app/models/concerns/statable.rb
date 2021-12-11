# frozen_string_literal: true

module Statable
  extend ActiveSupport::Concern

  MP = 'MP'
  GS = 'GS'
  A  = 'A'
  CS = 'CS'
  GC = 'GC'
  OG = 'OG'
  PS = 'PS'
  PM = 'PM'
  YC = 'YC'
  RC = 'RC'
  S  = 'S'
  B  = 'B'

  FOOTBALL_STATS = [MP, GS, A, CS, GC, OG, PS, PM, YC, RC, S, B].freeze

  included do
    after_initialize :generate_default_statistic
  end

  private

  def generate_default_statistic
    return if id

    self.statistic = select_default_statistic.index_with(0)
  end

  def select_default_statistic
    case Sports.position(position_kind)['sport_kind']
    when Sportable::FOOTBALL then FOOTBALL_STATS
    else []
    end
  end
end

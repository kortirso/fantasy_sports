# frozen_string_literal: true

class Sport < ApplicationRecord
  FOOTBALL   = 'football'
  BASKETBALL = 'basketball'
  HOCKEY     = 'hockey'

  has_many :leagues, dependent: :destroy

  has_many :sports_positions, class_name: 'Sports::Position', inverse_of: :sport, dependent: :destroy

  enum kind: { FOOTBALL => 0, BASKETBALL => 1, HOCKEY => 2 }
end

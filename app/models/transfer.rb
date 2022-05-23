# frozen_string_literal: true

class Transfer < ApplicationRecord
  OUT = 'out'
  IN = 'in'

  belongs_to :week
  belongs_to :fantasy_team
  belongs_to :teams_player, class_name: '::Teams::Player'

  enum direction: { OUT => -1, IN => 1 }
end

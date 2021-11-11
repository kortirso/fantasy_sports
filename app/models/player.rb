# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :sports_position, class_name: 'Sports::Position', foreign_key: :sports_position_id

  delegate :sport, to: :sports_position
end

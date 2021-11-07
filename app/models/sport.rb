# frozen_string_literal: true

class Sport < ApplicationRecord
  has_many :leagues, dependent: :destroy

  has_many :sports_positions, class_name: 'Sports::Position', inverse_of: :sport, dependent: :destroy
end

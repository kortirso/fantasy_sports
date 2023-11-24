# frozen_string_literal: true

class Injury < ApplicationRecord
  belongs_to :players_season, class_name: '::Players::Season', touch: true

  scope :active, -> { where(return_at: nil).or(where('return_at > ?', DateTime.now)) }
  scope :inactive, -> { where.not(return_at: nil).where('return_at < ?', DateTime.now) }
end

# frozen_string_literal: true

class League < ApplicationRecord
  belongs_to :sport

  has_many :seasons, dependent: :destroy
  has_one :active_season, -> { Season.active }, class_name: 'Season', foreign_key: :league_id
end

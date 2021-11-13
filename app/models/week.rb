# frozen_string_literal: true

class Week < ApplicationRecord
  belongs_to :leagues_season, class_name: '::Leagues::Season'

  has_many :games, dependent: :destroy

  scope :active, -> { where(active: true) }
end

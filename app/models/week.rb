# frozen_string_literal: true

class Week < ApplicationRecord
  belongs_to :leagues_season, class_name: '::Leagues::Season'

  scope :active, -> { where(active: true) }
end

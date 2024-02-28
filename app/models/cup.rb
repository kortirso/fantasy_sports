# frozen_string_literal: true

class Cup < ApplicationRecord
  include Uuidable
  include Placeable

  belongs_to :league

  scope :active, -> { where(active: true) }
  scope :coming, -> { where(active: false) }
end

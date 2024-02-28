# frozen_string_literal: true

class Cup < ApplicationRecord
  include Uuidable
  include Placeable

  belongs_to :league

  has_many :cups_rounds, class_name: '::Cups::Round', foreign_key: :cup_id, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :coming, -> { where(active: false) }
end

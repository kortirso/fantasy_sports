# frozen_string_literal: true

class OraculPlace < ApplicationRecord
  include Uuidable

  belongs_to :placeable, polymorphic: true # Season/Cup

  scope :active, -> { where(active: true) }
end

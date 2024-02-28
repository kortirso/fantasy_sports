# frozen_string_literal: true

module Placeable
  extend ActiveSupport::Concern

  included do
    has_many :oracul_places, as: :placeable, dependent: :destroy
    has_many :oracul_leagues, -> { distinct }, through: :oracul_places
    has_many :oraculs, -> { distinct }, through: :oracul_places
  end
end

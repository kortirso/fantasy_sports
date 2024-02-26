# frozen_string_literal: true

module Oraculs
  class Lineup < ApplicationRecord
    self.table_name = :oraculs_lineups

    include Uuidable

    belongs_to :oracul, class_name: '::Oracul', foreign_key: :oracul_id
    belongs_to :periodable, polymorphic: true # Week/Cups::Round
  end
end

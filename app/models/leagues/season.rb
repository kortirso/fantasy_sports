# frozen_string_literal: true

module Leagues
  class Season < ApplicationRecord
    self.table_name = :leagues_seasons

    belongs_to :league
  end
end

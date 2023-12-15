# frozen_string_literal: true

module Games
  class ExternalSource < ApplicationRecord
    self.table_name = :games_external_sources

    include Sourceable

    belongs_to :game
  end
end

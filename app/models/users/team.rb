# frozen_string_literal: true

module Users
  class Team < ApplicationRecord
    self.table_name = :users_teams

    belongs_to :user
  end
end

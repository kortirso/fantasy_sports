# frozen_string_literal: true

class FantasyLeague < ApplicationRecord
  belongs_to :leagueable, polymorphic: true
end

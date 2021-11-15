# frozen_string_literal: true

class FantasyLeague < ApplicationRecord
  belongs_to :leagueable, polymorphic: true
  belongs_to :leagues_season, class_name: '::Leagues::Season'
end

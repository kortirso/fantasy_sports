# frozen_string_literal: true

class League < ApplicationRecord
  belongs_to :sport

  has_many :leagues_seasons, class_name: 'Leagues::Season', inverse_of: :league, dependent: :destroy
end

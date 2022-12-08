# frozen_string_literal: true

class Cup < ApplicationRecord
  belongs_to :fantasy_league

  has_many :cups_rounds, class_name: '::Cups::Round', foreign_key: :cup_id, dependent: :destroy
end

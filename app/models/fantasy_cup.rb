# frozen_string_literal: true

class FantasyCup < ApplicationRecord
  include Uuidable

  belongs_to :fantasy_league

  has_many :fantasy_cups_rounds, class_name: '::FantasyCups::Round', foreign_key: :cup_id, dependent: :destroy
  has_many :fantasy_cups_pairs, class_name: '::FantasyCups::Pair', through: :cups_rounds
end

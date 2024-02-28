# frozen_string_literal: true

module Periodable
  extend ActiveSupport::Concern

  included do
    has_many :oraculs_lineups,
             class_name: '::Oraculs::Lineup',
             as: :periodable,
             dependent: :destroy
  end
end

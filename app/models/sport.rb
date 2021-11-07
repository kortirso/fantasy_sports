# frozen_string_literal: true

class Sport < ApplicationRecord
  has_many :leagues, dependent: :destroy
end

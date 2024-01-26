# frozen_string_literal: true

class Identity < ApplicationRecord
  TELEGRAM = 'telegram'
  GOOGLE = 'google'

  belongs_to :user

  enum provider: { TELEGRAM => 0, GOOGLE => 1 }
end

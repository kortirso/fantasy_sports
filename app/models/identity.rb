# frozen_string_literal: true

class Identity < ApplicationRecord
  TELEGRAM = 'telegram'
  GOOGLE = 'google'

  encrypts :email, deterministic: true

  belongs_to :user

  enum provider: { TELEGRAM => 0, GOOGLE => 1 }
end

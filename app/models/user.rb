# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password

  has_many :fantasy_teams, dependent: :destroy

  enum role: { regular: 0, admin: 1 }
end

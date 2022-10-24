# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword
  include Leagueable

  has_secure_password

  has_many :fantasy_teams, dependent: :destroy
  has_many :lineups, through: :fantasy_teams

  has_one :users_session, class_name: 'Users::Session', dependent: :destroy

  enum role: { regular: 0, admin: 1 }
end

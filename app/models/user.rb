# frozen_string_literal: true

class User < ApplicationRecord
  include ActiveModel::SecurePassword
  include Leagueable
  include Kudos::Achievementable

  has_secure_password
  has_secure_token :confirmation_token, length: 24
  has_secure_token :restore_token, length: 24

  has_many :fantasy_teams, dependent: :destroy
  has_many :lineups, through: :fantasy_teams

  has_many :users_sessions, class_name: 'Users::Session', dependent: :destroy
  has_many :feedbacks, dependent: :destroy

  scope :not_confirmed, -> { where(confirmed_at: nil) }

  enum role: { regular: 0, admin: 1 }

  def confirmed?
    confirmed_at.present?
  end
end

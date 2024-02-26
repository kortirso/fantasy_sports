# frozen_string_literal: true

class OraculLeague < ApplicationRecord
  include Uuidable

  has_secure_token :invite_code, length: 24

  belongs_to :oracul_place
  belongs_to :leagueable, polymorphic: true, optional: true # User/Week/Cup/nil

  has_many :oracul_leagues_members,
           class_name: '::OraculLeagues::Member',
           foreign_key: :oracul_league_id,
           dependent: :destroy

  has_many :oraculs, through: :oracul_leagues_members

  scope :invitational, -> { where(leagueable_type: 'User') }
  scope :general, -> { where.not(leagueable_type: 'User').or(where(leagueable_type: nil)) }

  def invitational?
    leagueable_type == 'User'
  end
end

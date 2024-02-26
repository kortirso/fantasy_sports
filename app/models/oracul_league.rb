# frozen_string_literal: true

class OraculLeague < ApplicationRecord
  include Uuidable

  has_secure_token :invite_code, length: 24

  belongs_to :oracul_place
  belongs_to :leagueable, polymorphic: true, optional: true # User/Week/Cup/nil

  scope :invitational, -> { where(leagueable_type: 'User') }
  scope :general, -> { where.not(leagueable_type: 'User') }

  def invitational?
    leagueable_type == 'User'
  end
end

# frozen_string_literal: true

class Oracul < ApplicationRecord
  include Uuidable

  belongs_to :user
  belongs_to :oracul_place

  has_many :oracul_leagues_members,
           class_name: '::OraculLeagues::Member',
           foreign_key: :oracul_id,
           dependent: :destroy

  has_many :oracul_leagues, through: :oracul_leagues_members
end

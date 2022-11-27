# frozen_string_literal: true

class AchievementGroup < ApplicationRecord
  include Uuidable

  belongs_to :parent, class_name: 'AchievementGroup', foreign_key: :parent_id, inverse_of: :children, optional: true

  has_many :children, class_name: 'AchievementGroup', foreign_key: :parent_id, inverse_of: :parent, dependent: :nullify

  has_many :achievements, dependent: :destroy
end

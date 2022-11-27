# frozen_string_literal: true

module Users
  class Achievement < ApplicationRecord
    self.table_name = :users_achievements

    belongs_to :user, class_name: '::User'
    belongs_to :achievement, class_name: '::Achievement'

    scope :unread, -> { where(notified: false) }
  end
end

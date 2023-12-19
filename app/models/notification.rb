# frozen_string_literal: true

class Notification < ApplicationRecord
  DEADLINE_DATA = 'deadline_data'

  TELEGRAM = 'telegram'

  belongs_to :notifyable, polymorphic: true

  enum notification_type: {
    DEADLINE_DATA => 0
  }
  enum target: { TELEGRAM => 0 }
end

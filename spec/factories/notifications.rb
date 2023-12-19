# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    notification_type { Notification::DEADLINE_DATA }
    target { Notification::TELEGRAM }
    notifyable factory: %i[user]
  end
end

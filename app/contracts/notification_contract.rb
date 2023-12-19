# frozen_string_literal: true

class NotificationContract < ApplicationContract
  config.messages.namespace = :notification

  params do
    required(:target).filled(:string)
    required(:notification_type).filled(:string)
  end

  rule(:target) do
    if Notification.targets.keys.exclude?(values[:target])
      key(:target).failure(:unexisting)
    end
  end
end

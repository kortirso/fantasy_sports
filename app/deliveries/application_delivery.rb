# frozen_string_literal: true

class ApplicationDelivery < ActiveDelivery::Base
  self.abstract_class = true

  register_line :telegram, ActiveDelivery::Lines::Notifier,
                resolver_pattern: 'Telegram::%{delivery_name}Notifier'
end

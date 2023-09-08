# frozen_string_literal: true

class Sport < FrozenRecord::Base
  self.base_path = Rails.root.join('config/settings')
  self.backend = FrozenRecord::Backends::Json
end

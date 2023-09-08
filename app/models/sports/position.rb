# frozen_string_literal: true

module Sports
  class Position < FrozenRecord::Base
    self.base_path = Rails.root.join('config/settings')
    self.backend = FrozenRecord::Backends::Json
  end
end

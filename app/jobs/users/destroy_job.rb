# frozen_string_literal: true

module Users
  class DestroyJob < ApplicationJob
    queue_as :default

    def perform(id:)
      user = User.find_by(id: id)
      return unless user

      user.destroy
    end
  end
end

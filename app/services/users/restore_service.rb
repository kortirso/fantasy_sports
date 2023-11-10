# frozen_string_literal: true

module Users
  class RestoreService
    def call(user:)
      Users::Auth::SendRestoreLinkJob.perform_now(id: user.id)
    end
  end
end

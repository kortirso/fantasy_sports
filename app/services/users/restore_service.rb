# frozen_string_literal: true

module Users
  class RestoreService
    include Deps[update_service: 'services.persisters.users.update']

    def call(user:)
      # commento: users.reset_password_sent_at
      update_service.call(user: user, params: { reset_password_sent_at: DateTime.now })
      Users::Auth::SendRestoreLinkJob.perform_now(id: user.id)
    end
  end
end

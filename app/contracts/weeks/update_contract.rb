# frozen_string_literal: true

module Weeks
  class UpdateContract < ApplicationContract
    config.messages.namespace = :week

    params do
      optional(:deadline_at)
    end
  end
end

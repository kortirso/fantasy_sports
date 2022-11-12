# frozen_string_literal: true

module Lineups
  class UpdateContract < ApplicationContract
    config.messages.namespace = :lineup

    params do
      optional(:active_chips).array(:string)
    end

    rule(:active_chips) do
      if values[:active_chips].size != values[:active_chips].uniq.size
        key.failure(I18n.t('dry_validation.errors.lineup.active_chips_duplicates'))
      end
      # TODO: add check for active_chips limit
    end
  end
end

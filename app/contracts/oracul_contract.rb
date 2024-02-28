# frozen_string_literal: true

class OraculContract < ApplicationContract
  config.messages.namespace = :oracul

  params do
    required(:name).filled(:string)
  end
end

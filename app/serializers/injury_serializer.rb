# frozen_string_literal: true

class InjurySerializer < ApplicationSerializer
  set_id nil

  attributes :reason, :status, :return_at
end

# frozen_string_literal: true

module Weeks
  class UpdateForm
    include Deps[validator: 'validators.weeks.update']

    def call(week:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      week.update!(params)

      { result: week.reload }
    end
  end
end

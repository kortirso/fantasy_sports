# frozen_string_literal: true

class ApplicationOperator
  include ServiceOperator::Helpers

  private

  def use_transaction(operator)
    ActiveRecord::Base.transaction do
      operator.call
    end
  end
end

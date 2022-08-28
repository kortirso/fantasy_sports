# frozen_string_literal: true

class ApplicationOperator
  include ServiceOperator

  private

  def use_transaction(operator)
    ActiveRecord::Base.transaction do
      operator.call
    end
  end
end

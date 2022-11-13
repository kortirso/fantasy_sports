# frozen_string_literal: true

module Parameterable
  extend ActiveSupport::Concern

  InvalidInputParamsError = Class.new(StandardError)

  private

  def schema_params(params:, schema:, required: nil)
    params = params.require(required) if required
    result = schema.call(params.to_unsafe_h)
    raise Parameterable::InvalidInputParamsError.new if result.errors.any?

    result.output
  end

  def invalid_params
    json_response_with_errors('Invalid input params', 422)
  end
end

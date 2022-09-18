# frozen_string_literal: true

ServiceOperator.configure do |config|
  config.call_parameters_method_name = :call_parameters
  config.failure_method_name = :failure?
end

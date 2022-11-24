# frozen_string_literal: true

module ApplicationService
  def self.prepended(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def call(args={})
      new.call(args)
    end
  end

  attr_reader :errors, :result

  def initialize(args={})
    super(**args)
    @errors = []
  end

  def call(args={})
    super(**args)
    self
  end

  def success?
    !failure?
  end

  def failure?
    @errors.any?
  end

  def call_parameters
    method(:call).super_method.parameters
  end

  private

  def fails!(messages)
    @errors = messages
  end

  def fail!(message)
    @errors.push(message)
  end
end

# frozen_string_literal: true

module ApplicationService
  module ClassMethods
    def call(args={})
      new.call(args)
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
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

  private

  def validate_with(validator, params={})
    errors = validator.call(params: params)
    fails!(errors) if errors.any?
  end

  def fails!(messages)
    @errors = messages
  end

  def fail!(message)
    @errors.push(message)
  end
end

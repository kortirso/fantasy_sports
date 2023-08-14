# frozen_string_literal: true

module Cacheable
  extend ActiveSupport::Concern

  private

  def cached_response(**, &block)
    Rails.cache.fetch(cache_key(**), &block)
  end

  def cache_key(payload:, name:, version:)
    [
      name,
      payload.respond_to?(:maximum) ? :list : payload.id,
      version,
      payload.respond_to?(:maximum) ? payload.maximum(:updated_at).to_i : payload.updated_at.to_i
    ].join('-')
  end
end

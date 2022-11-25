# frozen_string_literal: true

class Achievement < ApplicationRecord
  include Uuidable

  belongs_to :user

  scope :unread, -> { where(notified: false) }

  class << self
    def ranks
      @ranks ||= []
    end

    def rank(rank, options={})
      ranks << { rank: rank, requirement: options[:requirement], points: options[:points] }
    end
  end
end

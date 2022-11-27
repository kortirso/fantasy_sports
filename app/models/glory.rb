# frozen_string_literal: true

module Glory
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def awards
      @awards ||= {}
    end

    def award_for(award_name, &block)
      awards[award_name] = block
    end

    def award(award_name, *attributes)
      achievements = Achievement.where(award_name: award_name.to_s).order(rank: :asc)
      awards[award_name].call(achievements, *attributes)
    end
  end
end

# frozen_string_literal: true

module Achievements
  module FantasyTeams
    class Create < Achievement
      # one time achievement, no need to check levels
      def self.award_for(fantasy_team:)
        user = fantasy_team.user
        user.award(achievement: self, points: 5) unless user.awarded?(achievement: self)
      end

      def self.title
        { 'en' => 'Beginning', 'ru' => 'Начало' }
      end

      def self.description
        {
          'en' => 'Create fantasy team for any sport',
          'ru' => 'Создайте фэнтези команду для любого вида спорта'
        }
      end
    end
  end
end

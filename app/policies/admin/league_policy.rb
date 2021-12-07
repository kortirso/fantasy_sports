# frozen_string_literal: true

module Admin
  class LeaguePolicy < ApplicationPolicy
    def show?
      user.admin?
    end
  end
end

# frozen_string_literal: true

module Admin
  class LeaguesController < AdminController
    before_action :find_leagues

    def index; end

    private

    def find_leagues
      @leagues = League.all
    end
  end
end

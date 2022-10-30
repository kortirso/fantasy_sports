# frozen_string_literal: true

module Sports
  class RulesController < ApplicationController
    before_action :find_sport, only: %i[index]

    def index; end

    private

    def find_sport
      sport = Sports.sport(params[:sport_id])
      page_not_found unless sport
    end
  end
end

# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_leagues

  def show; end

  private

  def find_leagues
    @leagues = League.all.group_by { |league| league.sport_kind }
  end
end

# frozen_string_literal: true

class HomesController < ApplicationController
  before_action :find_sports

  def show; end

  private

  def find_sports
    @sports = Sport.order(id: :asc).includes(:leagues)
  end
end

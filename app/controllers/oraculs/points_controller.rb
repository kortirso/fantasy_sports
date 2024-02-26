# frozen_string_literal: true

module Oraculs
  class PointsController < ApplicationController
    before_action :find_oracul

    def index; end

    private

    def find_oracul
      @oracul = Oracul.find_by!(uuid: params[:oracul_id])
    end
  end
end

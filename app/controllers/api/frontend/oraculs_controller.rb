# frozen_string_literal: true

module Api
  module Frontend
    class OraculsController < ApplicationController
      include Deps[create_form: 'forms.oraculs.create']

      before_action :find_oracul_place, only: %i[create]

      def create
        # commento: oraculs.name
        case create_form.call(user: current_user, oracul_place: @oracul_place, params: oracul_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result } then render json: { result: result }, status: :ok
        end
      end

      private

      def find_oracul_place
        @oracul_place = OraculPlace.active.find_by!(uuid: params[:oracul_place_id])
      end

      def oracul_params
        params.require(:oracul).permit(:name)
      end
    end
  end
end

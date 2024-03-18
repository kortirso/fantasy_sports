# frozen_string_literal: true

module Api
  module V1
    class OraculsController < Api::V1Controller
      include Deps[create_form: 'forms.oraculs.create']

      before_action :find_oracul_place, only: %i[create]

      SERIALIZER_FIELDS = %w[id name oracul_place_id].freeze

      def index
        render json: { oraculs: oraculs }, status: :ok
      end

      def create
        # commento: oraculs.name
        case create_form.call(user: current_user, oracul_place: @oracul_place, params: oracul_params)
        in { errors: errors } then render json: { errors: errors }, status: :ok
        in { result: result }
          render json: {
            result: OraculSerializer.new(
              result, params: serializer_fields(OraculSerializer, SERIALIZER_FIELDS)
            ).serializable_hash
          }, status: :ok
        end
      end

      private

      def oraculs
        OraculSerializer.new(
          Current.user.oraculs.order(id: :desc), params: serializer_fields(OraculSerializer, SERIALIZER_FIELDS)
        ).serializable_hash
      end

      def find_oracul_place
        @oracul_place = OraculPlace.active.find(params[:oracul_place_id])
      end

      def oracul_params
        params.require(:oracul).permit(:name)
      end
    end
  end
end

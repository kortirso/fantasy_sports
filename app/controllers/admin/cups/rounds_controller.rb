# frozen_string_literal: true

module Admin
  module Cups
    class RoundsController < Admin::BaseController
      include Deps[create_form: 'forms.cups.rounds.create']

      before_action :find_cups_rounds, only: %i[index]
      before_action :find_cup, only: %i[new create]

      def index; end

      def new
        @cups_round = ::Cups::Round.new
      end

      def create
        case create_form.call(cup: @cup, params: cup_params)
        in { errors: errors } then redirect_to new_admin_cup_round_path(cup_id: params[:cup_id]), alert: errors
        else
          redirect_to(
            admin_cup_rounds_path(cup_id: params[:cup_id]), notice: t('controllers.admin.cups.rounds.create.success')
          )
        end
      end

      private

      def find_cups_rounds
        @cups_rounds =
          ::Cups::Round
            .where(cup_id: params[:cup_id])
            .order(position: :asc)
            .hashable_pluck(:id, :name, :position)
      end

      def find_cup
        @cup = Cup.find(params[:cup_id])
      end

      def cup_params
        params.require(:cups_round).permit(:name, :position)
      end
    end
  end
end

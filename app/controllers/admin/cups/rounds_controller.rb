# frozen_string_literal: true

module Admin
  module Cups
    class RoundsController < Admin::BaseController
      include Deps[
        create_form: 'forms.cups.rounds.create',
        update_form: 'forms.cups.rounds.update'
      ]

      before_action :find_cups_rounds, only: %i[index]
      before_action :find_cup, only: %i[new edit create update]
      before_action :find_cups_round_for_edit, only: %i[edit update]
      before_action :find_cups_round, only: %i[refresh_oraculs_points]

      def index; end

      def new
        @cups_round = ::Cups::Round.new
      end

      def edit; end

      def create
        case create_form.call(cup: @cup, params: cup_params)
        in { errors: errors } then redirect_to new_admin_cup_round_path(cup_id: params[:cup_id]), alert: errors
        else
          redirect_to(
            admin_cup_rounds_path(cup_id: params[:cup_id]), notice: t('controllers.admin.cups.rounds.create.success')
          )
        end
      end

      def update
        case update_form.call(cups_round: @cups_round, params: cup_params)
        in { errors: errors }
          redirect_to edit_admin_cup_round_path(cup_id: params[:cup_id], id: params[:id]), alert: errors
        else
          redirect_to(
            admin_cup_rounds_path(cup_id: params[:cup_id]), notice: t('controllers.admin.cups.rounds.update.success')
          )
        end
      end

      def refresh_oraculs_points
        ::Oraculs::Lineups::Points::UpdateJob.perform_later(
          periodable_id: @cups_round.id,
          periodable_type: 'Cups::Round'
        )
        redirect_to(
          admin_cup_rounds_path(cup_id: @cups_round.cup_id),
          notice: t('controllers.admin.cups.rounds.refresh_oraculs_points')
        )
      end

      private

      def find_cups_rounds
        @cups_rounds =
          ::Cups::Round
            .where(cup_id: params[:cup_id])
            .order(position: :asc)
            .hashable_pluck(:id, :name, :position, :status)
      end

      def find_cup
        @cup = Cup.find(params[:cup_id])
      end

      def find_cups_round_for_edit
        @cups_round = @cup.cups_rounds.find(params[:id])
      end

      def find_cups_round
        @cups_round = ::Cups::Round.find(params[:cups_round_id])
      end

      def cup_params
        params.require(:cups_round).permit(:name, :position, :status)
      end
    end
  end
end

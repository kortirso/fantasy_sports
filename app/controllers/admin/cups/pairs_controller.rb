# frozen_string_literal: true

module Admin
  module Cups
    class PairsController < Admin::BaseController
      include Deps[
        create_form: 'forms.cups.pairs.create',
        update_form: 'forms.cups.pairs.update'
      ]

      before_action :find_cups_pairs, only: %i[index]
      before_action :find_cups_round, only: %i[new edit create update]
      before_action :find_cups_pair, only: %i[edit update]

      def index; end

      def new
        @cups_pair = ::Cups::Pair.new
      end

      def edit; end

      def create
        case create_form.call(cups_round: @cups_round, params: cups_pair_params)
        in { errors: errors }
          redirect_to new_admin_cups_round_pair_path(cups_round_id: params[:cups_round_id]), alert: errors
        else
          redirect_to(
            admin_cups_round_pairs_path(cups_round_id: params[:cups_round_id]),
            notice: t('controllers.admin.cups.pairs.create.success')
          )
        end
      end

      def update
        case update_form.call(cups_pair: @cups_pair, params: cups_pair_params)
        in { errors: errors }
          redirect_to(
            edit_admin_cups_round_pair_path(cups_round_id: params[:cups_round_id], id: @cups_pair.id),
            alert: errors
          )
        else
          redirect_to(
            admin_cups_round_pairs_path(cups_round_id: params[:cups_round_id]),
            notice: t('controllers.admin.cups.pairs.update.success')
          )
        end
      end

      private

      def find_cups_pairs
        @cups_pairs =
          ::Cups::Pair
            .where(cups_round_id: params[:cups_round_id])
            .order(start_at: :asc)
            .hashable_pluck(:id, :home_name, :visitor_name, :start_at, :points)
      end

      def find_cups_round
        @cups_round = ::Cups::Round.find(params[:cups_round_id])
      end

      def find_cups_pair
        @cups_pair = @cups_round.cups_pairs.find(params[:id])
      end

      # rubocop: disable Metrics/AbcSize
      def cups_pair_params
        params
          .require(:cups_pair)
          .permit(:home_name, :visitor_name)
          .to_h
          .merge(
            start_at: params[:cups_pair][:start_at].present? ? DateTime.parse(params[:cups_pair][:start_at]) : nil,
            points: params[:cups_pair][:points].present? ? params[:cups_pair][:points].split('-') : []
          )
      end
      # rubocop: enable Metrics/AbcSize
    end
  end
end

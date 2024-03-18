# frozen_string_literal: true

module Api
  module V1
    module Cups
      class PairsController < Api::V1Controller
        include Deps[cups_pairs_query: 'queries.cups.pairs']

        before_action :find_cups_pairs, only: %i[index]

        SERIALIZER_FIELDS = %w[id points predictable start_at home_name visitor_name].freeze

        def index
          render json: {
            cups_pairs: ::Cups::PairSerializer.new(
              @cups_pairs, params: serializer_fields(::Cups::PairSerializer, SERIALIZER_FIELDS)
            ).serializable_hash
          }, status: :ok
        end

        private

        def find_cups_pairs
          @cups_pairs = cups_pairs_query.resolve(params: params).order(start_at: :asc)
        end
      end
    end
  end
end

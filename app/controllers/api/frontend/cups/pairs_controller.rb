# frozen_string_literal: true

module Api
  module Frontend
    module Cups
      class PairsController < ApplicationController
        include Deps[cups_pairs_query: 'queries.cups.pairs']

        before_action :find_cups_pairs, only: %i[index]

        def index
          render json: {
            cups_pairs: ::Cups::PairSerializer.new(
              @cups_pairs, params: { include_fields: %w[id points predictable start_at home_name visitor_name] }
            ).serializable_hash
          }, status: :ok
        end

        private

        def find_cups_pairs
          @cups_pairs = cups_pairs_query.resolve(params: params)
        end
      end
    end
  end
end

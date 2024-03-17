# frozen_string_literal: true

module Cups
  class PairsQuery
    def resolve(relation: Cups::Pair.all, params: {})
      relation = relation.where(cups_round_id: params[:cups_round_id]) if params[:cups_round_id].present?
      relation
    end
  end
end

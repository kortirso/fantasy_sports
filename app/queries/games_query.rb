# frozen_string_literal: true

class GamesQuery
  def resolve(relation: Game.all, params: {})
    relation = relation.where(week_id: params[:week_id]) if params[:week_id].present?
    relation
  end
end

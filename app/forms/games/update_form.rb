# frozen_string_literal: true

module Games
  class UpdateForm
    include Deps[validator: 'validators.games.update']

    # rubocop: disable Metrics/AbcSize
    def call(game:, params:)
      errors = validator.call(params: params)
      return { errors: errors } if errors.any?

      new_week = Week.future.find_by(season_id: game.week.season_id, id: params[:week_id]) if params[:week_id].present?
      return { errors: ['Week does not exist'] } if params[:week_id].present? && new_week.nil?

      ActiveRecord::Base.transaction do
        game.games_players.destroy_all if new_week.nil? || new_week.status == Week::INACTIVE
        game.update!(params)
      end

      { result: game.reload }
    end
    # rubocop: enable Metrics/AbcSize
  end
end

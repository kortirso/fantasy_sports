class AddAveragePointsToPlayersSeasons < ActiveRecord::Migration[7.0]
  def change
    add_column :players_seasons, :average_points, :decimal, precision: 8, scale: 2, null: false, default: 0.0
    add_column :players_seasons, :form, :decimal, precision: 8, scale: 2, null: false, default: 0.0
  end
end

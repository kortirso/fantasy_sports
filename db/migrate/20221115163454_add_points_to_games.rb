class AddPointsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :points, :integer, array: true, null: false, default: []
  end
end

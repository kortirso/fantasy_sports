class AddPoints < ActiveRecord::Migration[7.0]
  def change
    add_column :games_players, :points, :integer
    add_column :lineups_players, :points, :integer
    add_column :lineups, :points, :integer, null: false, default: 0
  end
end

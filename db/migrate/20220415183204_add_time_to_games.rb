class AddTimeToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :start_at, :datetime
    add_column :weeks, :deadline_at, :datetime
  end
end

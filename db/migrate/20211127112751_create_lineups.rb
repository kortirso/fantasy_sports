class CreateLineups < ActiveRecord::Migration[7.0]
  def change
    create_table :lineups do |t|
      t.integer :fantasy_team_id
      t.integer :week_id
      t.timestamps
    end
    add_index :lineups, [:fantasy_team_id, :week_id], unique: true
  end
end

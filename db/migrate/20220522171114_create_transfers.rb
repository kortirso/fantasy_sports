class CreateTransfers < ActiveRecord::Migration[7.0]
  def change
    create_table :transfers do |t|
      t.integer :week_id, index: true
      t.integer :fantasy_team_id, index: true
      t.integer :teams_player_id, index: true
      t.integer :direction, null: false, default: 1
      t.timestamps
    end
  end
end

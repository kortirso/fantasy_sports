class CreateLineupsPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :lineups_players do |t|
      t.integer :lineup_id
      t.integer :teams_player_id
      t.boolean :active, null: false, default: false
    end
    add_index :lineups_players, [:lineup_id, :teams_player_id], unique: true, name: 'lineup_player_index'
  end
end

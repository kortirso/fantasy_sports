class CreateGamesPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :games_players do |t|
      t.integer :game_id
      t.integer :player_id
      t.jsonb :statistic, null: false, default: {}
      t.timestamps
    end
    add_index :games_players, [:game_id, :player_id], unique: true
  end
end

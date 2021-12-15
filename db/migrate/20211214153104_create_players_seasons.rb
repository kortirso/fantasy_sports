class CreatePlayersSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :players_seasons do |t|
      t.integer :player_id
      t.integer :season_id
      t.integer :points, null: false, default: 0
      t.jsonb :statistic, null: false, default: {}
      t.timestamps
    end
    add_index :players_seasons, [:player_id, :season_id], unique: true
  end
end

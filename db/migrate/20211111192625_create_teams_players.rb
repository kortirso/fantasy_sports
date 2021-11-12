class CreateTeamsPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :teams_players do |t|
      t.integer :leagues_seasons_team_id
      t.integer :player_id
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :teams_players, [:leagues_seasons_team_id, :player_id]
  end
end

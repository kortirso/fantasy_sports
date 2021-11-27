class CreateFantasyTeamsLineupsPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :fantasy_teams_lineups_players do |t|
      t.integer :fantasy_teams_lineup_id
      t.integer :teams_player_id
      t.timestamps
    end
    add_index :fantasy_teams_lineups_players, [:fantasy_teams_lineup_id, :teams_player_id], unique: true, name: 'lineup_player_index'
  end
end

class CreateFantasyTeamsPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :fantasy_teams_players do |t|
      t.integer :fantasy_team_id
      t.integer :teams_player_id
      t.timestamps
    end
    add_index :fantasy_teams_players, [:fantasy_team_id, :teams_player_id], unique: true, name: 'fantasy_teams_and_players_index'
  end
end

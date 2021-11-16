class CreateFantasyLeaguesTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :fantasy_leagues_teams do |t|
      t.integer :fantasy_league_id
      t.integer :fantasy_team_id
      t.timestamps
    end
    add_index :fantasy_leagues_teams, [:fantasy_league_id, :fantasy_team_id], unique: true, name: 'fantasy_team_index'
  end
end

class CreateLeaguesSeasonsTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :leagues_seasons_teams do |t|
      t.integer :leagues_season_id
      t.integer :team_id
      t.timestamps
    end
    add_index :leagues_seasons_teams, [:leagues_season_id, :team_id], unique: true
  end
end

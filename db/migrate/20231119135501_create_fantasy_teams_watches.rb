class CreateFantasyTeamsWatches < ActiveRecord::Migration[7.1]
  def change
    create_table :fantasy_teams_watches do |t|
      t.bigint :fantasy_team_id, null: false
      t.bigint :players_season_id, null: false
      t.timestamps
    end
    add_index :fantasy_teams_watches, [:fantasy_team_id, :players_season_id], unique: true
  end
end

class CreateSeasonsTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons_teams do |t|
      t.integer :season_id
      t.integer :team_id
      t.timestamps
    end
    add_index :seasons_teams, [:season_id, :team_id], unique: true
  end
end

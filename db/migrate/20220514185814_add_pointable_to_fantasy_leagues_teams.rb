class AddPointableToFantasyLeaguesTeams < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :fantasy_leagues_teams, :pointable_id, :integer
    add_column :fantasy_leagues_teams, :pointable_type, :string
    add_index :fantasy_leagues_teams, [:pointable_id, :pointable_type], algorithm: :concurrently
    safety_assured { remove_column :fantasy_leagues_teams, :fantasy_team_id }
  end
end

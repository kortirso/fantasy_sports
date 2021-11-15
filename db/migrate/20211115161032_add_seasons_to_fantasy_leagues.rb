class AddSeasonsToFantasyLeagues < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :fantasy_leagues, :leagues_season_id, :integer
    add_index :fantasy_leagues, :leagues_season_id, algorithm: :concurrently
  end
end

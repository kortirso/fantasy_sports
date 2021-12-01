class AddSeasonsToFantasyLeagues < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :fantasy_leagues, :season_id, :integer
    add_index :fantasy_leagues, :season_id, algorithm: :concurrently
  end
end

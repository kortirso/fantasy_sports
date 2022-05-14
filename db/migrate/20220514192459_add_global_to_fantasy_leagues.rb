class AddGlobalToFantasyLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_leagues, :global, :boolean, null: false, default: true
  end
end

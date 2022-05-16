class AddUuidToFantasyLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_leagues, :uuid, :uuid, null: false, index: true
  end
end

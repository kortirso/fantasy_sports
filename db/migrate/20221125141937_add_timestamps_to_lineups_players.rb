class AddTimestampsToLineupsPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :lineups_players, :created_at, :datetime, null: false
    add_column :lineups_players, :updated_at, :datetime, null: false
  end
end

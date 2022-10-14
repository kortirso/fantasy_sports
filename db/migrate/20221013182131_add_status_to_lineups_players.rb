class AddStatusToLineupsPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :lineups_players, :status, :integer, null: false, default: 0
  end
end

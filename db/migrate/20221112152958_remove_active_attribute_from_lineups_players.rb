class RemoveActiveAttributeFromLineupsPlayers < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :lineups_players, :active }
  end
end

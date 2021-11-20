class AddPriceToTeamsPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :teams_players, :price_cents, :integer, null: false, default: 0
  end
end

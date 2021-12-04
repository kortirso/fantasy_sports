class AddTransfersForSports < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :free_transfers, :integer, null: false, default: 0
  end
end

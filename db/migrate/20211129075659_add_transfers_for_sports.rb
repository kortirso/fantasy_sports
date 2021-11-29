class AddTransfersForSports < ActiveRecord::Migration[7.0]
  def change
    add_column :sports, :free_transfers_per_week, :integer, null: false, default: 1
    add_column :sports, :points_per_transfer, :integer, null: false, default: 1
    add_column :fantasy_teams, :free_transfers, :integer, null: false, default: 0
  end
end

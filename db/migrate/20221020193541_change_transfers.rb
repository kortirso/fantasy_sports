class ChangeTransfers < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :transfers, :week_id
      remove_column :transfers, :fantasy_team_id
      remove_column :fantasy_teams, :free_transfers
      remove_column :fantasy_teams, :transfers_limited
    end

    add_column :transfers, :lineup_id, :bigint, index: true
    add_column :lineups, :free_transfers_amount, :integer, null: false, default: 0
    add_column :lineups, :transfers_limited, :boolean, default: true
    add_column :lineups, :penalty_points, :integer, null: false, default: 0
  end
end

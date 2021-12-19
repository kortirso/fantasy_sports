class AddTransfersLimitedToFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :transfers_limited, :boolean, null: false, default: false
  end
end

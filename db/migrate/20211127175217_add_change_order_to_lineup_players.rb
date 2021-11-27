class AddChangeOrderToLineupPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams_lineups_players, :change_order, :integer, null: false, default: 0
  end
end

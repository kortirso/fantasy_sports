class AddPointsToFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :points, :integer, null: false, default: 0
  end
end

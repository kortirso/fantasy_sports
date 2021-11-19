class AddCompletedToFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :completed, :boolean, null: false, default: false
  end
end

class AddCurrentPlaceToTeams < ActiveRecord::Migration[7.1]
  def change
    add_column :fantasy_leagues_teams, :current_place, :integer, null: false, default: 1
  end
end

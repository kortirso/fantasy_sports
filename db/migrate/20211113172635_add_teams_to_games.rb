class AddTeamsToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :home_season_team_id, :integer, index: true
    add_column :games, :visitor_season_team_id, :integer, index: true
  end
end

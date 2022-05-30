class ChangePointsToFloat < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_column :games_players, :points, :float
      change_column :fantasy_teams, :points, :float
      change_column :lineups, :points, :float
      change_column :lineups_players, :points, :float
      change_column :players, :points, :float
      change_column :players_seasons, :points, :float
    end
  end
end

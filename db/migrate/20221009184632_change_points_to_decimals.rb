class ChangePointsToDecimals < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      change_column :games_players, :points, :decimal, precision: 8, scale: 2
      change_column :fantasy_teams, :points, :decimal, precision: 8, scale: 2
      change_column :lineups, :points, :decimal, precision: 8, scale: 2
      change_column :lineups_players, :points, :decimal, precision: 8, scale: 2
      change_column :players, :points, :decimal, precision: 8, scale: 2
      change_column :players_seasons, :points, :decimal, precision: 8, scale: 2
    end
  end

  def down
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

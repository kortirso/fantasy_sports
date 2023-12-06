class AddSelectedByTeamsRatioToPlayersSeasons < ActiveRecord::Migration[7.1]
  def change
    add_column :players_seasons, :selected_by_teams_ratio, :integer, null: false, default: 0
  end
end

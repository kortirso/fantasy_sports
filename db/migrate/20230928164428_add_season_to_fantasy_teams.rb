class AddSeasonToFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :season_id, :bigint, null: false, index: true
  end
end

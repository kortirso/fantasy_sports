class AddSeasonsTeamToGamesPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :games_players, :seasons_team_id, :bigint, null: false, index: true
  end
end

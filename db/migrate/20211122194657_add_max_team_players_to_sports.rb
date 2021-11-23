class AddMaxTeamPlayersToSports < ActiveRecord::Migration[7.0]
  def change
    add_column :sports, :max_team_players, :integer, null: false, default: 1
  end
end

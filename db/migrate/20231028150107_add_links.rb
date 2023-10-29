class AddLinks < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      add_column :teams_players, :players_season_id, :bigint, index: true

      Teams::Player.where(active: false).destroy_all
      Teams::Player.all.map do |teams_player|
        players_season =
          Players::Season.find_or_create_by(
            season_id: teams_player.seasons_team.season_id,
            player_id: teams_player.player_id
          )
        teams_player.update(players_season_id: players_season.id)
      end

      change_column_null :teams_players, :players_season_id, false
    end
  end
end

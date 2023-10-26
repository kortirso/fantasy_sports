class RemoveRedundantGamesPlayers < ActiveRecord::Migration[7.0]
  def change
    # remove games_players from inactive weeks
    week_ids = Week.where(status: ['inactive']).ids
    Games::Player.joins(:game).where(games: { week_id: week_ids }).destroy_all

    # add games_players for manually created teams_players
    week_ids = Week.where(status: ['active', 'coming']).ids
    Teams::Player
      .where.missing(:games_players)
      .includes(:player)
      .hashable_pluck(:id, :seasons_team_id, 'players.position_kind').each do |teams_player|
        games_players = teams_player.seasons_team.games.where(week_id: week_ids).map do |game|
          {
            game_id: game.id,
            teams_player_id: teams_player[:id],
            position_kind: teams_player[:players_position_kind],
            seasons_team_id: teams_player[:seasons_team_id]
          }
        end

        Games::Player.upsert_all(games_players) if games_players.any?
      end
  end
end

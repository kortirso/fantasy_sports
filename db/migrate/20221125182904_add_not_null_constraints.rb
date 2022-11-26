class AddNotNullConstraints < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      change_column_null :fantasy_leagues, :leagueable_id, false
      change_column_null :fantasy_leagues, :leagueable_type, false
      change_column_null :fantasy_leagues, :season_id, false
      change_column_null :fantasy_leagues_teams, :fantasy_league_id, false
      change_column_null :fantasy_leagues_teams, :pointable_id, false
      change_column_null :fantasy_leagues_teams, :pointable_type, false
      change_column_null :fantasy_teams, :user_id, false
      change_column_null :fantasy_teams_players, :fantasy_team_id, false
      change_column_null :fantasy_teams_players, :teams_player_id, false
      change_column_null :games, :week_id, false
      change_column_null :games, :home_season_team_id, false
      change_column_null :games, :visitor_season_team_id, false
      change_column_null :games_players, :game_id, false
      change_column_null :games_players, :teams_player_id, false
      change_column_null :lineups, :fantasy_team_id, false
      change_column_null :lineups, :week_id, false
      change_column_null :lineups_players, :lineup_id, false
      change_column_null :lineups_players, :teams_player_id, false
      change_column_null :players_seasons, :player_id, false
      change_column_null :players_seasons, :season_id, false
      change_column_null :seasons, :league_id, false
      change_column_null :seasons_teams, :season_id, false
      change_column_null :seasons_teams, :team_id, false
      change_column_null :teams_players, :seasons_team_id, false
      change_column_null :teams_players, :player_id, false
      change_column_null :transfers, :teams_player_id, false
      change_column_null :transfers, :lineup_id, false
      change_column_null :weeks, :season_id, false
    end
  end
end

class ChangeRelationshipIdsToBigints < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      change_column :users_sessions, :user_id, :bigint
      change_column :transfers, :fantasy_team_id, :bigint
      change_column :transfers, :teams_player_id, :bigint
      change_column :fantasy_leagues_teams, :pointable_id, :bigint
      change_column :players_seasons, :player_id, :bigint
      change_column :players_seasons, :season_id, :bigint
      change_column :lineups_players, :lineup_id, :bigint
      change_column :lineups_players, :teams_player_id, :bigint
      change_column :lineups, :fantasy_team_id, :bigint
      change_column :lineups, :week_id, :bigint
      change_column :fantasy_teams_players, :fantasy_team_id, :bigint
      change_column :fantasy_teams_players, :teams_player_id, :bigint
      change_column :fantasy_teams_players, :teams_player_id, :bigint
      change_column :fantasy_leagues_teams, :fantasy_league_id, :bigint
      change_column :fantasy_teams, :user_id, :bigint
      change_column :fantasy_leagues, :season_id, :bigint
      change_column :fantasy_leagues, :leagueable_id, :bigint
      change_column :games_players, :game_id, :bigint
      change_column :games_players, :teams_player_id, :bigint
      change_column :games, :home_season_team_id, :bigint
      change_column :games, :visitor_season_team_id, :bigint
      change_column :games, :week_id, :bigint
      change_column :weeks, :season_id, :bigint
      change_column :teams_players, :seasons_team_id, :bigint
      change_column :teams_players, :player_id, :bigint
      change_column :seasons_teams, :season_id, :bigint
      change_column :seasons_teams, :team_id, :bigint
      change_column :seasons, :league_id, :bigint
    end
  end

  def down
    safety_assured do
      change_column :users_sessions, :user_id, :integer
      change_column :transfers, :fantasy_team_id, :integer
      change_column :transfers, :teams_player_id, :integer
      change_column :fantasy_leagues_teams, :pointable_id, :integer
      change_column :players_seasons, :player_id, :integer
      change_column :players_seasons, :season_id, :integer
      change_column :lineups_players, :lineup_id, :integer
      change_column :lineups_players, :teams_player_id, :integer
      change_column :lineups, :fantasy_team_id, :integer
      change_column :lineups, :week_id, :integer
      change_column :fantasy_teams_players, :fantasy_team_id, :integer
      change_column :fantasy_teams_players, :teams_player_id, :integer
      change_column :fantasy_teams_players, :teams_player_id, :integer
      change_column :fantasy_leagues_teams, :fantasy_league_id, :integer
      change_column :fantasy_teams, :user_id, :integer
      change_column :fantasy_leagues, :season_id, :integer
      change_column :fantasy_leagues, :leagueable_id, :integer
      change_column :games_players, :game_id, :integer
      change_column :games_players, :teams_player_id, :integer
      change_column :games, :home_season_team_id, :integer
      change_column :games, :visitor_season_team_id, :integer
      change_column :games, :week_id, :integer
      change_column :weeks, :season_id, :integer
      change_column :teams_players, :seasons_team_id, :integer
      change_column :teams_players, :player_id, :integer
      change_column :seasons_teams, :season_id, :integer
      change_column :seasons_teams, :team_id, :integer
      change_column :seasons, :league_id, :integer
    end
  end
end

class AddFantasyLeaguesTeamsCountToFantasyLeagues < ActiveRecord::Migration[7.1]
  def up
    add_column :fantasy_leagues, :fantasy_leagues_teams_count, :integer, null: false, default: 0

    FantasyLeague.reset_column_information
    FantasyLeague.find_each do |fantasy_league|
      FantasyLeague.update_counters fantasy_league.id, fantasy_leagues_teams_count: fantasy_league.fantasy_leagues_teams.size
    end
  end

  def down
    remove_column :fantasy_leagues, :fantasy_leagues_teams_count
  end
end

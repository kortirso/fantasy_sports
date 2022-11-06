class AddStatisticsToLineupPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :lineups_players, :statistic, :jsonb, null: false, default: {}
  end
end

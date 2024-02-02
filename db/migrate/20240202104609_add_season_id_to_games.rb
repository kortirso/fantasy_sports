class AddSeasonIdToGames < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_column :games, :season_id, :bigint
    add_index :games, :season_id, algorithm: :concurrently

    Game.includes(:week).find_each do |game|
      game.update(season_id: game.week.season_id)
    end
  end

  def down
    remove_column :games, :season_id
  end
end

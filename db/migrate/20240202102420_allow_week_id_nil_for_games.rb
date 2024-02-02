class AllowWeekIdNilForGames < ActiveRecord::Migration[7.1]
  def up
    change_column_null :games, :week_id, true
  end

  def down
    Game.where(week_id: nil).destroy_all
    change_column_null :games, :week_id, false
  end
end

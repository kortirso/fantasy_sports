class ReplaceMaintenanceToSeasons < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      add_column :seasons, :maintenance, :boolean, null: false, default: false
      remove_column :leagues, :maintenance
    end
  end

  def down
    safety_assured do
      add_column :leagues, :maintenance, :boolean, null: false, default: false
      remove_column :seasons, :maintenance
    end
  end
end

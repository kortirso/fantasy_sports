class AddMaintenanceToLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues, :maintenance, :boolean, null: false, default: false
  end
end

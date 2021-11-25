class AddStatusToWeeks < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :weeks, :active }
    add_column :weeks, :status, :integer, null: false, default: 0
  end
end

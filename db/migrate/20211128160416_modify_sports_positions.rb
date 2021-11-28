class ModifySportsPositions < ActiveRecord::Migration[7.0]
  def change
    add_column :sports_positions, :kind, :integer, null: false, default: 0
    add_column :sports_positions, :default_amount, :integer, null: false, default: 1
  end
end

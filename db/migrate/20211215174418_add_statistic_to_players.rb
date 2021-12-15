class AddStatisticToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :points, :integer, null: false, default: 0
    add_column :players, :statistic, :jsonb, null: false, default: {}
  end
end

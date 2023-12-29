class RemoveRedundantFields < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :teams_players, :form
      remove_column :teams_players, :shirt_number
      remove_column :players, :points
      remove_column :players, :statistic
    end
  end
end

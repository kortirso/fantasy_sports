class AddFinalPointsToLineups < ActiveRecord::Migration[7.1]
  def change
    add_column :lineups, :final_points, :boolean, null: false, default: false, comment: 'Flag shows that points is completely calculated, no more changes'
  end
end

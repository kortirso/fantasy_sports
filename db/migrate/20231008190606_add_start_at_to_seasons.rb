class AddStartAtToSeasons < ActiveRecord::Migration[7.0]
  def change
    add_column :seasons, :start_at, :datetime
  end
end

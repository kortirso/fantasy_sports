class AddSourceToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :source, :integer
    add_column :games, :external_id, :string
  end
end

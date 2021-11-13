class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.integer :week_id, index: true
      t.timestamps
    end
  end
end

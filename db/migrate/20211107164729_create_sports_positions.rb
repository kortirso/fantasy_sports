class CreateSportsPositions < ActiveRecord::Migration[7.0]
  def change
    create_table :sports_positions do |t|
      t.integer :sport_id, index: true
      t.jsonb :name, null: false, default: {}
      t.integer :total_amount, null: false, default: 0
      t.integer :min_game_amount, null: false, default: 0
      t.integer :max_game_amount, null: false, default: 0
      t.timestamps
    end
  end
end

class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.jsonb :name, null: false, default: {}
      t.integer :sports_position_id, index: true
      t.timestamps
    end
  end
end

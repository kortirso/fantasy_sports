class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.jsonb :name, null: false, default: {}
      t.integer :position_kind, null: false, default: 0
      t.timestamps
    end
  end
end

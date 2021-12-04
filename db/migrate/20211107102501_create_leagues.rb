class CreateLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :leagues do |t|
      t.integer :sport_kind, null: false, default: 0
      t.jsonb :name, null: false, default: {}
      t.timestamps
    end
  end
end

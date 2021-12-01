class CreateSeasons < ActiveRecord::Migration[7.0]
  def change
    create_table :seasons do |t|
      t.integer :league_id, index: true
      t.string :name, null: false, default: ''
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end

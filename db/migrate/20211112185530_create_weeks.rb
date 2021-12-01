class CreateWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :weeks do |t|
      t.integer :season_id, index: true
      t.integer :position, null: false, default: 1
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end

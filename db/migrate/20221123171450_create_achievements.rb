class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.string :type, null: false
      t.integer :rank
      t.integer :points
      t.bigint :user_id, null: false
      t.boolean :notified, null: false, default: false
      t.timestamps
    end
    add_index :achievements, [:type, :user_id], unique: true
  end
end

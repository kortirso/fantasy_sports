class CreateUsersAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :users_achievements do |t|
      t.bigint :user_id, null: false
      t.bigint :achievement_id, null: false
      t.boolean :notified, null: false, default: false
      t.integer :rank
      t.integer :points
      t.jsonb :title, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.timestamps
    end
    add_index :users_achievements, [:user_id, :achievement_id], unique: true
  end
end

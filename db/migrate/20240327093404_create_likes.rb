class CreateLikes < ActiveRecord::Migration[7.1]
  def change
    create_table :likes do |t|
      t.bigint :likeable_id, null: false
      t.string :likeable_type, null: false
      t.bigint :user_id, null: false
      t.timestamps
    end
    add_index :likes, [:user_id, :likeable_id, :likeable_type], unique: true
  end
end

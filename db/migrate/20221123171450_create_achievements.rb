class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.string :award_name, null: false, index: true
      t.integer :rank
      t.integer :points
      t.jsonb :title, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.timestamps
    end
  end
end

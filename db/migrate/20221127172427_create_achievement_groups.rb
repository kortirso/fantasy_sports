class CreateAchievementGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :achievement_groups do |t|
      t.uuid :uuid, null: false, index: { unique: true }
      t.bigint :parent_id, index: true
      t.integer :position, null: false, default: 0
      t.jsonb :name, null: false, default: {}
      t.timestamps
    end

    add_column :achievements, :achievement_group_id, :bigint, null: false, index: true
  end
end

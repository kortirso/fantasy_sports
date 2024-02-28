class CreateCupsForLeague < ActiveRecord::Migration[7.1]
  def change
    create_table :cups do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :league_id, null: false, index: true
      t.jsonb :name, null: false, default: {}
      t.boolean :active, null: false, default: false
      t.timestamps
    end
  end
end

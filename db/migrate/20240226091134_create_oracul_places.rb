class CreateOraculPlaces < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :oracul_places do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :placeable_id
      t.string :placeable_type
      t.jsonb :name, null: false, default: {}
      t.boolean :active, null: false, default: false
      t.timestamps
    end
    add_index :oracul_places, [:placeable_id, :placeable_type], algorithm: :concurrently
  end
end

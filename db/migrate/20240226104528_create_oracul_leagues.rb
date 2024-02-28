class CreateOraculLeagues < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :oracul_leagues do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :oracul_place_id, null: false, index: true
      t.bigint :leagueable_id
      t.string :leagueable_type
      t.string :name, null: false
      t.string :invite_code, index: true
      t.timestamps
    end
    add_index :oracul_leagues, [:leagueable_id, :leagueable_type], algorithm: :concurrently
  end
end

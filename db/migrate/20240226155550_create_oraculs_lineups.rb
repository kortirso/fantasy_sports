class CreateOraculsLineups < ActiveRecord::Migration[7.1]
  def change
    create_table :oraculs_lineups do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :oracul_id, null: false
      t.bigint :periodable_id, null: false
      t.string :periodable_type, null: false
      t.integer :points, null: false, default: 0
      t.timestamps
    end
    add_index :oraculs_lineups, [:oracul_id, :periodable_id, :periodable_type], unique: true, name: 'unique_oraculs_lineups_index'
  end
end

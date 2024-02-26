class CreateOraculs < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    create_table :oraculs do |t|
      t.uuid :uuid, null: false, index: true
      t.string :name
      t.bigint :user_id, null: false
      t.bigint :oracul_place_id, null: false, index: true
      t.integer :points, comment: 'Total points of oracul in place', null: false, default: 0
      t.timestamps
    end
    add_index :oraculs, [:user_id, :oracul_place_id], unique: true

    create_table :oracul_leagues_members do |t|
      t.bigint :oracul_league_id, null: false
      t.bigint :oracul_id, null: false
      t.timestamps
    end
    add_index :oracul_leagues_members, [:oracul_league_id, :oracul_id], unique: true
  end
end

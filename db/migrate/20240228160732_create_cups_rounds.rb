class CreateCupsRounds < ActiveRecord::Migration[7.1]
  def change
    create_table :cups_rounds do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :cup_id, null: false, index: true
      t.string :name, null: false
      t.integer :position, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end
  end
end

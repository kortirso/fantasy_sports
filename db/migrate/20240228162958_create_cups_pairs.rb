class CreateCupsPairs < ActiveRecord::Migration[7.1]
  def change
    create_table :cups_pairs do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :cups_round_id, null: false, index: true
      t.jsonb :home_name
      t.jsonb :visitor_name
      t.datetime :start_at
      t.integer :points, array: true, null: false, default: []
      t.timestamps
    end
  end
end

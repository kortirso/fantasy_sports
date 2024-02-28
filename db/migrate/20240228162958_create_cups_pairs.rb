class CreateCupsPairs < ActiveRecord::Migration[7.1]
  def change
    create_table :cups_pairs do |t|
      t.bigint :cups_round_id, null: false, index: true
      t.jsonb :home_name, null: false, default: {}
      t.jsonb :visitor_name, null: false, default: {}
      t.datetime :start_at
      t.integer :points, array: true, null: false, default: []
      t.timestamps
    end
  end
end

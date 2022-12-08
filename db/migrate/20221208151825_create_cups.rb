class CreateCups < ActiveRecord::Migration[7.0]
  def change
    create_table :cups do |t|
      t.bigint :fantasy_league_id, null: false, index: true
      t.string :name, null: false
      t.timestamps
    end

    create_table :cups_rounds do |t|
      t.bigint :cup_id, null: false, index: true
      t.bigint :week_id, null: false, index: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :cups_pairs do |t|
      t.bigint :cups_round_id, null: false, index: true
      t.bigint :home_lineup_id, null: false, index: true
      t.bigint :visitor_lineup_id, null: false, index: true
      t.timestamps
    end
  end
end

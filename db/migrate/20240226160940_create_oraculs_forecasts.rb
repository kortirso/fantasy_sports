class CreateOraculsForecasts < ActiveRecord::Migration[7.1]
  def change
    create_table :oraculs_forecasts do |t|
      t.uuid :uuid, null: false, index: true
      t.bigint :oraculs_lineup_id, null: false
      t.bigint :forecastable_id, null: false
      t.string :forecastable_type, null: false
      t.integer :value, array: true, null: false, default: []
      t.timestamps
    end
    add_index :oraculs_forecasts, [:oraculs_lineup_id, :forecastable_id, :forecastable_type], unique: true, name: 'unique_oraculs_forecasts_index'
  end
end

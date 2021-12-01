class AddUuidToSeasons < ActiveRecord::Migration[7.0]
  def change
    add_column :seasons, :uuid, :uuid, null: false, index: true
  end
end

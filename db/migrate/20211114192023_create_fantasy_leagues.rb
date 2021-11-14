class CreateFantasyLeagues < ActiveRecord::Migration[7.0]
  def change
    create_table :fantasy_leagues do |t|
      t.string :name, null: false, default: ''
      t.integer :leagueable_id
      t.string :leagueable_type
      t.timestamps
    end
    add_index :fantasy_leagues, [:leagueable_id, :leagueable_type]
  end
end

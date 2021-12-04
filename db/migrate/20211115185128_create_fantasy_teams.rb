class CreateFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :fantasy_teams do |t|
      t.uuid :uuid, null: false, index: true
      t.integer :user_id, index: true
      t.string :name, null: false, default: ''
      t.integer :sport_kind, null: false, default: 0
      t.timestamps
    end
  end
end

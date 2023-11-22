class CreateInjuries < ActiveRecord::Migration[7.1]
  def change
    create_table :injuries do |t|
      t.bigint :players_season_id, null: false, index: true
      t.jsonb :reason, null: false, default: {}, comment: 'Description of injury'
      t.datetime :return_at, comment: 'Potential return date'
      t.integer :status, null: false, default: 0, comment: 'Chance of playing from 0 to 100'
      t.timestamps
    end
  end
end

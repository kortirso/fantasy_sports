class AddUuidsToTables < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      add_column :lineups, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :weeks, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :teams_players, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :lineups_players, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :games_players, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :games, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
      add_column :teams, :uuid, :uuid, null: false, default: -> { 'gen_random_uuid()' }, index: true
    end
  end
end

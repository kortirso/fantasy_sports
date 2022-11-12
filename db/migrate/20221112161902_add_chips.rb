class AddChips < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :available_chips, :jsonb, null: false, default: {}
    add_column :lineups, :active_chips, :string, array: true, null: false, default: []
  end
end

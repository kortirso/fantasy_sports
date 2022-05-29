class AddFormToTeamsPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :teams_players, :form, :float, null: false, default: 0
  end
end

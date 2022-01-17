class AddNumberToTeamsPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :teams_players, :shirt_number, :integer
  end
end

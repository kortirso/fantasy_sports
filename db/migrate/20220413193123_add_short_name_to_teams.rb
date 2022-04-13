class AddShortNameToTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :short_name, :string
  end
end

class AddStringShirtNumber < ActiveRecord::Migration[7.0]
  def change
    add_column :teams_players, :shirt_number_string, :string

    Teams::Player.find_each do |teams_player|
      teams_player.update(shirt_number_string: teams_player.shirt_number.to_s)
    end
  end
end

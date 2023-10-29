class AddUuidToPlayersSeasons < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      add_column :players_seasons, :uuid, :uuid, index: true

      Players::Season.find_each { |players_season| players_season.update(uuid: SecureRandom.uuid) }

      change_column_null :players_seasons, :uuid, false
    end
  end

  def down
    remove_column :players_seasons, :uuid
  end
end

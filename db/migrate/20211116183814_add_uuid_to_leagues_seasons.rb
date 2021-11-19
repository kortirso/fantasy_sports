class AddUuidToLeaguesSeasons < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues_seasons, :uuid, :uuid, null: false, index: true
  end
end

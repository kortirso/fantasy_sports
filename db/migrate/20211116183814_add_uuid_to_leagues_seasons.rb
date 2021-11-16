class AddUuidToLeaguesSeasons < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues_seasons, :uuid, :uuid, null: false, default: 'gen_random_uuid()', index: true
  end
end

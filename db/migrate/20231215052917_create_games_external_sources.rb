class CreateGamesExternalSources < ActiveRecord::Migration[7.1]
  def change
    create_table :games_external_sources do |t|
      t.bigint :game_id, null: false, index: true
      t.integer :source, null: false, comment: 'External source name'
      t.string :external_id, null: false, comment: 'External ID'
      t.timestamps
    end

    add_column :seasons, :main_external_source, :string, comment: 'Main external source at the moment'

    Game.find_each do |game|
      Games::ExternalSource.create(game_id: game.id, source: game.source, external_id: game.external_id)
    end

    Season.find_each do |season|
      if season.league.sport_kind == 'basketball'
        season.update(main_external_source: Sourceable::SPORTRADAR)
      else
        season.update(main_external_source: Sourceable::SPORTS)
      end
    end
  end
end

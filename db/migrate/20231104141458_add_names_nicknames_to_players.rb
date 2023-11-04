class AddNamesNicknamesToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :first_name, :jsonb, null: false, default: {}
    add_column :players, :last_name, :jsonb, null: false, default: {}
    add_column :players, :nickname, :jsonb, null: false, default: {}

    Player.find_each do |player|
      existing_name = player.name
      player.update(
        first_name: { en: existing_name['en'].split(' ')[1], ru: existing_name['ru'].split(' ')[1] },
        last_name: { en: existing_name['en'].split(' ')[0], ru: existing_name['ru'].split(' ')[0] },
        nickname: { en: '', ru: '' }
      )
    end
  end
end

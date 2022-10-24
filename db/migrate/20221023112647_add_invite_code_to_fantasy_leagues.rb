class AddInviteCodeToFantasyLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_leagues, :invite_code, :string
  end
end

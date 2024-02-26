class AddOraculLeaguesMembersCount < ActiveRecord::Migration[7.1]
  def change
    add_column :oracul_leagues, :oracul_leagues_members_count, :integer, null: false, default: 0
  end
end

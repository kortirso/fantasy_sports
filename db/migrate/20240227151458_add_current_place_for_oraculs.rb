class AddCurrentPlaceForOraculs < ActiveRecord::Migration[7.1]
  def change
    add_column :oracul_leagues_members, :current_place, :integer, null: false, default: 1
  end
end

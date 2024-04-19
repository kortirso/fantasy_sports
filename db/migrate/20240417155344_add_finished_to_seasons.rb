class AddFinishedToSeasons < ActiveRecord::Migration[7.1]
  def change
    add_column :seasons, :status, :integer, null: false, default: 0

    Season.find_each do |season|
      season.update!(status: season.attributes['active'] ? Season::ACTIVE : Season::INACTIVE)
    end
  end
end

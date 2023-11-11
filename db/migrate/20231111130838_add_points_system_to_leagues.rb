class AddPointsSystemToLeagues < ActiveRecord::Migration[7.0]
  def change
    add_column :leagues, :points_system, :jsonb, null: false, default: {}, comment: 'Team points for game result in tournament'
    add_column :seasons, :members_count, :integer, null: false, default: 1, comment: 'Amount of teams in tournament'
    add_column :games, :difficulty, :integer, array: true, null: false, default: [3, 3], comment: 'Game difficulty for teams'
  end
end

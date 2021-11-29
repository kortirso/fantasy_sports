class AddBudgetCentsToFantasyTeams < ActiveRecord::Migration[7.0]
  def change
    add_column :fantasy_teams, :budget_cents, :integer, null: false, default: 10000
  end
end

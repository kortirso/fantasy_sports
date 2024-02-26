class RenameCupsToFantasyCups < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      rename_table :cups, :fantasy_cups
      rename_table :cups_rounds, :fantasy_cups_rounds
      rename_table :cups_pairs, :fantasy_cups_pairs
    end
  end
end

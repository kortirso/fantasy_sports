class AddTypeToCupsPairs < ActiveRecord::Migration[7.1]
  def change
    add_column :cups_pairs, :elimination_kind, :integer, null: false, default: 0
    add_column :cups_pairs, :required_wins, :integer
  end
end

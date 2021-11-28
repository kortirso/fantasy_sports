class AddKindToSports < ActiveRecord::Migration[7.0]
  def change
    add_column :sports, :kind, :integer, null: false, default: 0
  end
end

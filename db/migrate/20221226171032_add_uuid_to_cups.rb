class AddUuidToCups < ActiveRecord::Migration[7.0]
  def up
    safety_assured do
      add_column :cups, :uuid, :uuid, index: true

      Cup.find_each { |cup| cup.update(uuid: SecureRandom.uuid) }

      change_column_null :cups, :uuid, false
    end
  end

  def down
    remove_column :cups, :uuid
  end
end

class ChangeFieldsForEncryption < ActiveRecord::Migration[7.1]
  def up
    safety_assured do
      change_column :users, :username, :text
      change_column :users, :email, :text
      change_column :identities, :email, :text
    end
  end

  def down
    safety_assured do
      # encrypted value could have length more than 255 symbols
      User.find_each(&:decrypt)
      Identity.find_each(&:decrypt)

      change_column :users, :email, :string
      change_column :users, :username, :string
      change_column :identities, :email, :string
    end
  end
end

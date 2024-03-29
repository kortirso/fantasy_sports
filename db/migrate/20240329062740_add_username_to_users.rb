class AddUsernameToUsers < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    change_column_null :users, :email, true

    add_column :users, :username, :string
    add_index :users, :username, unique: true, algorithm: :concurrently
  end

  def down
    User.where(email: nil).destroy_all
    change_column_null :users, :email, false

    remove_column :users, :username
  end
end

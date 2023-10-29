class SessionsIndexNotUnique < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :users_sessions, :user_id
    add_index :users_sessions, :user_id, algorithm: :concurrently
  end
end

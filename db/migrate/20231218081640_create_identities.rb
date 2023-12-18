class CreateIdentities < ActiveRecord::Migration[7.1]
  def change
    create_table :identities do |t|
      t.bigint :user_id, null: false, index: true
      t.string :uid, null: false
      t.integer :provider, null: false, default: 0
      t.string :login
      t.string :email
      t.timestamps
    end
    add_index :identities, [:uid, :provider], unique: true
  end
end

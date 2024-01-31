class CreateBannedEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :banned_emails do |t|
      t.string :value, index: { unique: true }
      t.string :reason
      t.timestamps
    end
    add_column :users, :banned_at, :datetime
  end
end

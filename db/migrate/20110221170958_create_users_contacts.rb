class CreateUsersContacts < ActiveRecord::Migration
  def self.up
    create_table :users_contacts, :id => false do |t|
      t.integer :user_id
      t.integer :contact_id
      t.boolean :invited
      
      t.timestamps
    end
  end

  def self.down
    drop_table :users_contacts
  end
end

class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
      t.integer :user_info_id
      t.string :email
    end
  end

  def self.down
    drop_table :emails
  end
end

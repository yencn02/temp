class UserSecurityCode < ActiveRecord::Migration
  def self.up
    create_table :security_codes do |t|
      t.integer :user_id
      t.integer :security_code
      
      t.timestamps
    end
  end

  def self.down
    drop_table :security_codes
  end
end

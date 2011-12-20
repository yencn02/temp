class AddUserMobileNumber < ActiveRecord::Migration
  def self.up
    add_column :users, :mobile_number, :string, :null => false
  end

  def self.down
    remove_column :users, :mobile_number
  end
end

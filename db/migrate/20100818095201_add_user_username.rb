class AddUserUsername < ActiveRecord::Migration
  def self.up
    add_column :users, :username, :string, :null => false
  end

  def self.down
    remove_column :users, :username
  end
end

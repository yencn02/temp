class AddUnregisteredToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :unregistered, :boolean, :default => false
  end

  def self.down
    remove_column :users, :unregistered
  end
end

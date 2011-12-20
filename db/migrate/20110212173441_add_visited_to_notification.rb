class AddVisitedToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :visited, :boolean, :default => false;
  end

  def self.down
    remove_column :notifications, :visited
  end
end

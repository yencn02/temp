class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.column :friend_id, :integer
      t.column :user_id, :integer
      t.column :initiator, :boolean, :default => false
      t.column :friendship_status_id, :integer
      
      t.timestamps
    end
    
    create_table :friendship_statuses do |t|
      t.column :name, :string
    end    
  end

  def self.down
    drop_table :friendships
    drop_table :friendship_statuses
  end
end

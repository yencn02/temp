class CreateLikesTable < ActiveRecord::Migration
  def self.up
    create_table :likes, :force => true do |t|
        t.column "user_id", :integer, :default => 0, :null => false
        t.column "likable_type", :string, :limit => 15, :default => "", :null => false
        t.column "likable_id", :integer, :default => 0, :null => false
        t.timestamps
    end
    
    add_index :likes, :user_id, :name => 'fk_likes_user'
  end
  
  def self.down
    drop_table :likes
  end
end

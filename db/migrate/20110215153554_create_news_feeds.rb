class CreateNewsFeeds < ActiveRecord::Migration
  def self.up
    create_table :news_feeds do |t|
      t.integer :user_id
      t.string :content
      t.string :feed_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :news_feeds
  end
end

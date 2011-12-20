class DropPostNotificationsCreateNewsFeedsNotifications < ActiveRecord::Migration
  def self.up
    drop_table :post_notifications
    create_table :news_feed_notifications do |t|
      t.integer :news_feed_id
    end
  end

  def self.down
  end
end

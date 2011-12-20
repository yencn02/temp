class AddCityAndPrivacyToNewsFeeds < ActiveRecord::Migration
  def self.up
    add_column :news_feeds, :city_id, :integer, :default => 0
    add_column :news_feeds, :privacy, :integer
  end

  def self.down
    remove_column :news_feeds, :city_id
    remove_column :news_feeds, :privacy
  end
end

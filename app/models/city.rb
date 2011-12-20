class City < ActiveRecord::Base
  has_many :news_feeds
  has_many :addresses
  
  scope :cities_of_coutry, lambda { |*args| {:conditions => ["country_id = ?", args.first], :order => "name ASC"}}
end

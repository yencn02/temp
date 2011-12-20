class NewsFeed < ActiveRecord::Base
  require File.join(File.dirname(__FILE__), '../../lib/likable/acts_as_likable')
  include Notifier
  belongs_to :user
  belongs_to :city
  after_create :do_notifications
  acts_as_commentable
  
  SCOPE = {:my_connections => 0, :arround_me => 1}
  PRIVACY = {:everyone => -2, :my_connections => -1}
  
  scope :any_type_news_feeds, lambda { |*args| {:conditions => ["feed_type is not null"], :limit => 20, :order => "created_at DESC"}}
  scope :some_type_news_feeds, lambda { |*args| {:conditions => ["feed_type = ?", args.first], :limit => 20, :order => "created_at DESC"}}
  scope :friends_scope_news_feeds, lambda { |*args| {:conditions => ["user_id in (?)", args.first], :limit => 20, :order => "created_at DESC"}}
  scope :city_scope_news_feeds, lambda { |*args| {:conditions => ["city_id like ?", args.first], :limit => 20, :order => "created_at DESC"}}

  #Manual acts_as_likable
  has_many :likes, :as => :likable, :dependent => :destroy
  include Acts::Likable::InstanceMethods
  extend Acts::Likable::SingletonMethods

  def NewsFeed.prepare_news_feeds(current_user, filter_type, filter_scope)
    me_and_my_friends_ids = current_user.friends_ids << current_user.id    
    # TODO: remove the * from here and define it as a constant
    # this applies for any * in this functions
    filter_type = filter_type.nil? ? '*' : filter_type
    filter_scope = filter_scope.nil? ? SCOPE[:my_connections] : filter_scope.to_i
    
    # TODO: you can write news_feed = if .... 
    # then remove all "news_feed =" inside the if
    news_feeds = nil
    if filter_scope == SCOPE[:my_connections]
      if filter_type == '*'
        news_feeds = NewsFeed.any_type_news_feeds.friends_scope_news_feeds(me_and_my_friends_ids);
      else
        news_feeds = NewsFeed.some_type_news_feeds(filter_type).friends_scope_news_feeds(me_and_my_friends_ids);
      end  
    elsif filter_scope == SCOPE[:arround_me]
      if filter_type == '*'
        news_feeds = NewsFeed.any_type_news_feeds.city_scope_news_feeds('%');
      else
        news_feeds = NewsFeed.some_type_news_feeds(filter_type).city_scope_news_feeds('%');
      end
    end
    
    # TODO: use inject instead of each
    final_results = []
    news_feeds.each do |news_feed|
      privacy = news_feed.privacy
        begin
        task_condition = true
        # TODO: why use "and" and not "&&"
        # "and" is used to solve operator precendence issues
        if news_feed.feed_type == "Task" and Task.find(news_feed.content.to_i).cant?
          task_condition = false
        end
        if task_condition and privacy == PRIVACY[:everyone] #if open to everyone
          final_results << news_feed
        elsif task_condition and privacy == PRIVACY[:my_connections] #if connections only can see it
          if news_feed.user.friendship_exists_with(current_user)
            final_results << news_feed
          end  
        elsif task_condition #if task_list_id, then only users who are can see this task list are invited to see
          if TaskList.find(privacy).accessible_for_user?(current_user)
            final_results << news_feed
          end
        end
      rescue
      	# TODO: make sure this is the required action
        puts "bad hive"
      end
    end
    
    return final_results
  end

  def from_user_id
    user_id
  end
  
  def to_user_id
    user_id
  end

  def do_notifications
    if self.feed_type == 'Task' && (Task.find(self.content).assigner != Task.find(self.content).assignee)
      if privacy == PRIVACY[:my_connections] or privacy == PRIVACY[:everyone]
        recipients = user.friends_ids - [Task.find(self.content).assigner.id]
      else
        recipients = []
        editors = TaskList.find(privacy).editors
        editors.each do |e|
          recipients << e.id
        end
      end
      send_notification({:type => 'NewsFeedNotification', :feeder => user.id, :recipients => recipients, :news_feed_id => self.id})
    end  
  end
  
end

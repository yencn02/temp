class Friendship < ActiveRecord::Base
  extend FriendshipClassMethods  

  @@daily_request_limit = 12
  cattr_accessor :daily_request_limit

  # destroy task list connections granted for this friend by the current user
  before_destroy :destroy_granted_task_lists_connections

  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"   
  has_enumerated :friendship_status, :class_name => 'FriendshipStatus', :foreign_key => 'friendship_status_id'

  validates_presence_of   :friendship_status, :user, :friend
  validates_uniqueness_of :friend_id, :scope => :user_id
  
  before_validation :set_pending, :on => :create
  
  scope :accepted, lambda { {:conditions => ["friendship_status_id = ?", FriendshipStatus[:accepted].id]} }
  scope :pending, lambda { {:conditions => ["friendship_status_id = ?", FriendshipStatus[:pending].id]} }
  scope :denied, lambda { {:conditions => ["friendship_status_id = ?", FriendshipStatus[:denied].id]} }
  
  
  validates_each :user_id do |record, attr, value|
    record.errors.add attr, 'can not be same as friend' if record.user_id.eql?(record.friend_id)
  end
  
  def validate  
    if new_record? && initiator && user.has_reached_daily_friend_request_limit?
      errors.add_to_base("Sorry, you'll have to wait a little while before requesting any more friendships.")       
    end
  end    
  
  attr_protected :friendship_status_id
  
  def destroy_granted_task_lists_connections
    granted_to = user.task_lists_connections.find_all_by_user_id(self.friend_id)
    granted_to.each(&:destroy)
  end
  
  def reverse
    Friendship.first(:conditions => {:user_id => self.friend_id, :friend_id => self.user_id})
  end

  def denied?
    friendship_status.eql?(FriendshipStatus[:denied])
  end
  
  def pending?
    friendship_status.eql?(FriendshipStatus[:pending])
  end
  
  def accepted?
    friendship_status.eql?(FriendshipStatus[:accepted])    
  end
    
  def accept!
    Friendship.accept(user_id, friend_id)
  end

  def breakup!
    Friendship.breakup(user_id, friend_id)
  end
  
  def deny!
    Friendship.deny(user_id, friend_id)
  end
      
  private
  
  def set_pending
    self.friendship_status_id = FriendshipStatus[:pending].id
  end
  
end

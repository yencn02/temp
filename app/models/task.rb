require 'notifier'

class Task < ActiveRecord::Base
  require File.join(File.dirname(__FILE__), '../../lib/likable/acts_as_likable')
  include Notifier
  after_create :do_notifications_and_hives
  acts_as_commentable
  acts_as_taggable

  belongs_to :assigner, :class_name => "User", :foreign_key => "from_user_id"
  belongs_to :assignee, :class_name => "User", :foreign_key => "to_user_id"  
  belongs_to :task_list

  has_enumerated :status, :class_name => 'TaskStatus', :foreign_key => 'status_id'

  scope :for, lambda { |user| {:conditions => {:to_user_id => user.id}}}
  scope :from, lambda { |user| {:conditions => ["from_user_id = ? and to_user_id <> ?", user.id, user.id]} }
  scope :for_or_from, lambda { |user| {:conditions => ["from_user_id = ? or to_user_id = ?", user.id, user.id]}}

  scope :task_list, lambda { |tl| {:conditions => (tl.blank? ? {} : {:task_list_id => tl.id})} }

  validates_presence_of :description
  validates_presence_of :assigner, :assignee, :task_list, :status

  attr_accessor :to_user_name

  delegate :pending?, :cant?, :did?, :will?, :cancelled?, :waiting?, :to => :status

  scope :pending, lambda { {:conditions => ['status_id = ? OR status_id = ?', TaskStatus[:waiting], TaskStatus[:will]]} }
  scope :waiting, lambda { {:conditions => ['status_id = ?', TaskStatus[:waiting]] } }
  scope :will, lambda { {:conditions => ['status_id = ?', TaskStatus[:will]] } }
  scope :did, lambda { {:conditions => ['status_id = ?', TaskStatus[:did]] } }
  scope :cant, lambda { {:conditions => ['status_id = ?', TaskStatus[:cant]] } }
  scope :cancelled, lambda { {:conditions => ['status_id = ?', TaskStatus[:cancelled]] } }
  scope :every

  scope :with_taggings, lambda {|taggable_ids| {:conditions=>['id in (?)', taggable_ids], :order => "created_at DESC"}}
  scope :with_id_in, lambda {|ids| {:conditions=>['id in (?)', ids]}}

  #Manual acts_as_likable
  has_many :likes, :as => :likable, :dependent => :destroy
  include Acts::Likable::InstanceMethods
  extend Acts::Likable::SingletonMethods

  #sends notifications to the assignee that he's been assigned a task
  #creates a hive for the task
  def do_notifications_and_hives
    send_notification({:type=>'TaskNotification', :task=>self})
    
    news_feed = NewsFeed.new({:user_id => self.to_user_id, :content => self.id, :feed_type => 'Task', :privacy => -2});
    news_feed.save
  end

  def notify_on_status_change(assigner_action = false)
    if assigner_action
      send_notification({:type=>"AssignerActionOnTaskNotification", :task=>self})
    else
      send_notification({:type=>"ActionOnTaskNotification", :task=>self})    
    end
  end

  def notify_on_reassign
    send_notification({:type=>"AssignerActionOnTaskNotification", :task=>self}) unless me? assignee
  end

  def change_status(status)
    self.status = TaskStatus[status.to_sym]
  end

  def status_formatted_name
    self.status.cant? ? "can't" : self.status.name
  end

  #TODO: use db queries instead of doing that here
  def is_spam? user
    assignee == user and !(user == assigner) and !assignee.accepted_friends.include?(assigner)
  end

  def add_multiple_tags(tags)
    tags = tags.split(',')
    tags.each do |tag|
      ts = tag.squeeze(" ").strip.split(' ')
      ts.each do |t|
        tag_list.add(t)
      end
    end
  end

end
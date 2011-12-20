require "digest/sha1"

class User < ActiveRecord::Base
  acts_as_spammable
  # Include default devise modules. Others available are:
  # :http_authenticatable, :token_authenticatable, :lockable, :timeoutable and :activatable
  devise :registerable, :database_authenticatable, :recoverable, :token_authenticatable,
         :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :first_name, :last_name,
                :avatar, :terms_of_service, :username, :mobile_number

  has_many :notifications

  has_many :task_lists, :dependent => :destroy, :order => "task_lists.id ASC" #order by task_lists.id rather than just id to avoid ambigiuty in task_lists.accessible_for named_scope
  has_many :default_task_lists, :class_name => "TaskList", :dependent => :destroy, 
           :conditions => "editable = false", :order => "task_lists.id ASC"
  has_many :for_me, :class_name => "Task", :foreign_key => "to_user_id", :dependent => :destroy, :order => "created_at desc" #, :conditions => ['not spam_state = ?', Badr::Acts::Spammable::Constants::SPAM]
  has_many :from_me, :class_name => "Task", :foreign_key => "from_user_id",
          :dependent => :destroy, :conditions => "to_user_id <> from_user_id", :order => "created_at desc"

  # By: Mohammad Abdelaziz
  # for importing google accounts
  has_one :google, :class_name => "GoogleToken", :dependent => :destroy

  has_and_belongs_to_many :contacts, :join_table => "users_contacts"

  #profile info
  has_one :user_info

  #news_feeds info
  has_many :news_feeds

  #security code for none registered users
  has_one :security_code

  # To be changed when friends are added
  has_many :connections, :finder_sql => 'select * from users where id <> #{id}', :class_name => "User"

  #friendship associations
  has_many :friendships, :class_name => "Friendship", :foreign_key => "user_id", :dependent => :destroy
  has_many :friends, :source => :friend, :through => :friendships
  has_many :accepted_friendships, :class_name => "Friendship", :conditions => ['friendship_status_id = ?', 2]
  has_many :accepted_friends, :source => :friend, :through => :accepted_friendships
  has_many :pending_friendships, :class_name => "Friendship", :conditions => ['initiator = ? AND friendship_status_id = ?', false, 1]
  has_many :pending_friends, :source => :friend, :through => :pending_friendships
  has_many :friendships_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', true], :dependent => :destroy
  has_many :friendships_not_initiated_by_me, :class_name => "Friendship", :foreign_key => "user_id", :conditions => ['initiator = ?', false], :dependent => :destroy
  has_many :occurances_as_friend, :class_name => "Friendship", :foreign_key => "friend_id", :dependent => :destroy

  validates_presence_of :first_name, :last_name, :username
  validates_length_of :first_name, :last_name, :username, :maximum => 20

  validates_acceptance_of :terms_of_service, :message => 'You must accept the terms of service', :on => :create

  after_create :add_default_task_lists, :create_user_info
  has_attached_file :avatar,
                  :styles => { :small => ["16x16#", :png], :medium => ["32x32#", :png] ,:thumb => "100x100#" },
                  :path => ":rails_root/system/:class/:attachment/:id/:style_:basename.:extension",
                  :url => "/images/users_avatars/:id/:style/:basename.:extension",
                  :default_url => "/images/missing_photo.png"

  def add_default_task_lists
    standard_lists = StandardTaskList.all
    standard_lists.each do |l|
      self.task_lists.create(:title => l.title, :icon_name => l.icon_name, :editable => false)
    end
  end

  def create_user_info
    UserInfo.new(:user_id => self.id).save
  end

  def tasks
    Task.for_or_from(self)
  end
  
  def default_task_list
    task_lists.find_by_title(StandardTaskList.default_task_list_title)
  end
  
  def task_lists_connections
    TaskListConnection.granted_by(self)
  end

  def pending_tasks
    self.for_me.pending.count
  end

  def pending_tasks_for_me_count
    self.for_me.pending.count
  end

  def pending_tasks_from_me_count
    self.from_me.pending.count
  end

  def total_tasks_for_me_count
    self.for_me.count - self.for_me.cancelled.count
  end

  def total_tasks_from_me_count
    self.from_me.count - self.from_me.cancelled.count
  end

  def pending_tasks_in_list(task_list)
    self.for_me.task_list(task_list).pending.count
  end

  def task_lists_granted_for_friend(friend)
    self.task_lists.accessible_for(friend)
  end

  def task_lists_granted_for_friend_count(friend)
    self.task_lists.accessible_for(friend).count
  end

  #first name + last name if user is registered, or just email
  #if user is unregistered
  def name
    unless unregistered_user?
      "#{first_name} #{last_name}"
    else
      "#{email}"
    end
  end
  
  #Titleized name if user is registered, or just email
  #if user is unregistered
  def formatted_name
    unless unregistered_user?
      "#{first_name} #{last_name}".titleize
    else
      "#{email}"
    end
  end

  def cheeve_it_mail
    name = unregistered_user? ? email : "#{username}@cheeve.it"
  end
  
  def current_user_matches_auto_complete_token? user, q
    user.first_name.match(q) || 
    user.last_name.match(q)  || 
    user.username.match(q)  || 
    user.email.match(q)
  end
  
  def auto_complete_friends(q, limit=20)
    users = [] #to ensure that users is not nil to avoid exceptions
    users << self if current_user_matches_auto_complete_token? self, q
    users.concat self.me_and_accepted_friends_first_name_starts_with q
    users.concat self.me_and_accepted_friends_last_name_starts_with q
    users.concat self.me_and_accepted_friends_user_name_starts_with q
    users.concat self.me_and_accepted_friends_first_name_like q
    users.concat self.me_and_accepted_friends_last_name_like q
    users.concat self.me_and_accepted_friends_user_name_like q
    users.concat self.me_and_accepted_friends_email_starts_with q    

    u_contacts = self.contacts_name_like(q)
    users.concat u_contacts if u_contacts #this is because u_contacts may return nil
    
    users.uniq! {|user| user.id} 
    
    users = users[0..limit-1]
  end

  #----------------------------------------------------------------------
  def me_and_accepted_friends_first_name_starts_with qname
    search_me_and_accepted_friends ["first_name LIKE ?", qname + '%'], "first_name"
  end

  def me_and_accepted_friends_last_name_starts_with qname
    search_me_and_accepted_friends ["last_name LIKE ?", qname + '%'], "first_name"
  end

  def me_and_accepted_friends_user_name_starts_with qname
    search_me_and_accepted_friends ["username LIKE ?", qname + '%'], "first_name"
  end
  #----------------------------------------------------------------------
  def me_and_accepted_friends_first_name_like qname
    search_me_and_accepted_friends ["first_name LIKE ?", '%' + qname + '%'], "first_name"
  end

  def me_and_accepted_friends_last_name_like qname
    search_me_and_accepted_friends ["last_name LIKE ?", '%' + qname + '%'], "first_name"
  end

  def me_and_accepted_friends_user_name_like qname
    search_me_and_accepted_friends ["username LIKE ?", '%' + qname + '%'], "first_name"
  end
  #----------------------------------------------------------------------
  def me_and_accepted_friends_name_starts_with qname
    search_me_and_accepted_friends ["CONCAT(LOWER(first_name), LOWER(last_name)) LIKE ?", qname + '%'], "first_name"
  end

  def me_and_accepted_friends_name_like qname
    search_me_and_accepted_friends ["CONCAT(LOWER(first_name), LOWER(last_name)) LIKE ?", '%' + qname + '%'], "first_name"
  end
  #----------------------------------------------------------------------
  def me_and_accepted_friends_email_starts_with qname
    search_me_and_accepted_friends ["email LIKE ?", qname + '%'], "first_name"
  end
  #----------------------------------------------------------------------
  def search_me_and_accepted_friends(conditions, order)
    result = [] #to ensure that result is not nil to avoid exceptions
    result.concat accepted_friends.find(:all,
                                        :conditions => conditions,
                                        :order => order)
    result
  end
  #----------------------------------------------------------------------
  def contacts_name_like(qname)
    u_contacts = [] #to ensure that u_contacts is not nil to avoid exceptions
    u_contacts.concat contacts.find(:all,
                                    :conditions => ["email LIKE ?", qname + '%'],
                                    :order => 'email')
    u_contacts.concat contacts.find(:all,
                                    :conditions => ["email LIKE ?", '%' + qname + '%'],
                                    :order => 'email')
    u_contacts.uniq! {|c| c.id}
    u_contacts.map{|c| User.find_by_email(c.email) || c}
  end
  #----------------------------------------------------------------------
  
  def friends_names
    names = ""
    self.friends.each do |f|
      names << "#{f.name},".downcase
    end
    names
  end

  def can_request_friendship_with(user)
    !self.eql?(user) && !self.friendship_exists_with?(user)
  end

  def friendship_exists_with?(friend)
    Friendship.find(:first, :conditions => ["user_id = ? AND friend_id = ?", self.id, friend.id])
  end

  def has_reached_daily_friend_request_limit?
    friendships_initiated_by_me.count(:conditions => ['created_at > ?', Time.now.beginning_of_day]) >= Friendship.daily_request_limit
  end

  def has_contact_email?(email)
    user_info.emails.each do |e|
      return true if e.email == email
    end
    return false
  end

  def friends_ids
    return [] if accepted_friendships.empty?
    accepted_friendships.map{|fr| fr.friend_id }
  end

  def unregistered_user?
    first_name == 'unregistered' && last_name == 'unregistered' && username == 'unregistered' && mobile_number == 'unregistered' && password_salt.blank? && encrypted_password.blank?
  end

  def User.user_exists_with_security_code?(user_id, security_code)
    begin
      u = User.find(user_id)
      u = u.security_code.security_code == security_code ? u : nil
    rescue
    u = nil
    end
  end

  def self.create_unregistered_user(email)
    u = User.new(:email => email, :first_name => 'unregistered', :last_name => 'unregistered', :username => 'unregistered', :mobile_number => 'unregistered', :unregistered => true)
    u.unregistered = true
    u.security_code = SecurityCode.generate(u.id, u.email)
    u.skip_confirmation!
    u.save(false)

    u
  end

  def self.generate(length = 10)
    Digest::SHA1.hexdigest(Time.now.to_s + rand(12341234).to_s)[1..length]
  end
  
  def admin?
    true
  end

end

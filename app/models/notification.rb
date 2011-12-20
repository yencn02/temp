require 'ruby-debug'

class Notification < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :user
  belongs_to :target_user, :class_name => "User", :foreign_key => "target_user_id" 
  
  scope :for_user,  lambda {|user_id|{:conditions => ["target_user_id = ?", user_id]}}
  scope :for_users, lambda {|users|  {:conditions => ["target_user_id in (?)", users]}}
  
  # TODO: use Time instead of Date
  scope :today,                      {:conditions => ["created_at >= ?", "#{Date.today.to_s} 00:00:00"]}
  scope :yesterday,                  {:conditions => ["created_at >= ? and created_at < ?", "#{Date.yesterday.to_s} 00:00:00", "#{Date.today.to_s} 00:00:00"]}
  scope :older_than_yesterday,       {:conditions => ["created_at < ?", "#{Date.yesterday.to_s} 00:00:00"]}
 
  # TODO: use {} instead of [] style for hash conditions
  scope :not_delivered_notifications,{:conditions => [:delivered_at => nil]}
  scope :unvisited,                  {:conditions => ["visited = false"]}
  scope :unvisited_ids,              {:select => :id, :conditions => ["visited = false"]}
  scope :grouped_count,              {:group => 'target_user_id', :select => '*, count(*)'}
  scope :ordered_by_creation_date,   {:order => "created_at DESC"}
 
  # This method deliver the notifications to
  # users
  def deliver(*params)
    type = ((resource_type == "TaskNotification") ? 
            (resource.resource.nil? ?
              resource_type.underscore : 
              resource.resource_type.underscore) : 
            resource_type.underscore)
    begin
      Mailer.send "deliver_#{type}", target_user, params[0]
    rescue
      Mailer.send "deliver_#{type}", target_user
    end
    
    update_attribute(:delivered_at, Time.now)
  end
  
  def notify_opened_browsers
    # notify open browser
    client = Juggernaut.show_clients.find{|client| client['client_id'] == target_user_id.to_s};
    
    logger.info '***************** (1) ' + client.inspect   
 
    if(client)
      client_id = client['client_id'] 
      count     = Notification.for_user(client_id).unvisited.grouped_count.count

      logger.info '***************** (2) ' + count.to_s

      data      = {:data_type               => 'new_notifications_count',
                   :new_notifications_count => count}

      Juggernaut.send_to_clients data , [client_id]
    end
  end
  
end

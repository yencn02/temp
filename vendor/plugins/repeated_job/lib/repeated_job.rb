require "active_support"

module Repeated
  class Job
    
    attr_reader :interval, :priority
    
    def initialize
      @interval = (ENV["REPEATED_JOB_INTERVAL"] || 1).to_i   # minutes
      @priority = (ENV["REPEATED_JOB_PRIORITY"] || 0).to_i
    end
    
    def perform
      schedule_next
      deliver_notifications
    end
    
    def schedule_next
      Delayed::Job.delete_all "handler like '%Repeated::Job%'"
      Delayed::Job.enqueue self, priority, interval.minutes.from_now.getutc
    end
    
    private 
    def deliver_notifications
         
      # find all not sent notifications
      notifications = Notification.not_delivered_notifications
      
      # sending notification mails
      notifications.each do |notification|
        notification.deliver # deliver the mail
      end
    end
  end
end

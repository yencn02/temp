#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  # find all not sent notification
  notifications = Notification.not_delivered_notifications
  
  # sending notifications
  notifications.each do |notification|
    notification.deliver
  end
  
  # sleep for 5 seconds
  # TODO: check the sleep time
  sleep 10
end
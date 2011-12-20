require "repeated_job"

# Added to fix a bug in the plugin
# http://www.mail-archive.com/heroku@googlegroups.com/msg05512.html
Delayed::Worker.backend = :active_record

begin
  cron = Repeated::Job.new
  cron.schedule_next
rescue StandardError
  puts "Exception encountered, Repeated::Job not loaded"
  puts $!
end
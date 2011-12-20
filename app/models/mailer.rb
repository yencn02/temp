class Mailer < ActionMailer::Base
  helper :application
  
  # Create by Ahmed Moawad
  # deliver email to unregistered user when assigned a task
  def task_to_unregistered_user(task)
    recipients    task.assignee.email
    from          "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject       "#{task.assigner.formatted_name} Assigned New #{task.task_list.title.titleize} Task for You"
    body          :task => task
    content_type  "text/html"
  end
  
  # TODO: from email should be loaded from a configuration file
  # depending on the running environment (development, production, test)
  
  # Created by Mohamed Magdy
  # a method to deliver a task_notification to user
  def task_notification(user, task)
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "#{task.assigner.formatted_name} Assigned New #{task.task_list.title.titleize} Task for You"
    body        :user => user, :task => task
    content_type  "text/html"
  end
  
  def action_on_task_notification(user, task)
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     task.status.did? ? "#{task.assignee.formatted_name} did your assigned task" : "#{task.assignee.formatted_name} #{task.status_formatted_name} do your assigned task"
    body        :user => user, :task => task
    content_type  "text/html"
  end
  
  def assigner_action_on_task_notification(user, task)
    c_subject = " marked a task as done for you"    if task.status == TaskStatus[:did]
    c_subject = " cancelled a task he assigned you" if task.status == TaskStatus[:cancelled]
    c_subject = " reassigned you a task he assigned you before" if task.status == TaskStatus[:waiting]
    
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "#{task.assigner.formatted_name}#{c_subject}"
    body        :user => user, :task => task, :c_subject => c_subject
    content_type  "text/html"
  end
  
  # Created by Mohamed Magdy
  # a method to deliver a comment_notification to user
  def comment_notification(user, comment)
    for_or_from = user.id == comment.commentable.from_user_id ? "from" : "for"
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "#{comment.user.formatted_name} commented on a task #{for_or_from} you"
    body        :user => user, :comment => comment
    content_type  "text/html"
  end
  
  def reminder_notification(user, task)
    recipients  user.email
    from          "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "#{task.assigner.formatted_name} Reminds you of this task"
    body        :user => user, :task => task
    content_type  "text/html"
  end
  
  # Created by Mohamed Magdy
  # a method to deliver a new_connection_notification to user
  def new_connection_notification(user, initiator)
    recipients  user.email
    from          "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "New Connection Request"
    body        :user => user, :initiator => initiator
    content_type  "text/html"
  end
  
  # Created by Mohamed Magdy
  # a method to deliver a connection_response_notification to user
  def connection_response_notification(user)
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "Connection Response"
    body        :user => user
    content_type  "text/html"
  end
  
  # Created by Mohamed Magdy
  # a method to deliver a post_task_notification to user
  def news_feed_notification(user)
    recipients  user.email
    from        "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     "News Feed Notification"
    body        :user => user
    content_type  "text/html"
  end
  
  # Created by Mohammad Abdelziz
  # The mail sent to invite someone to join cheever
  def invitation_to_cheeve_it(user, email)
    recipients  email
    from          "\"Cheeve\" <hzakareya.dev@gmail.com>"
    subject     user.formatted_name + " invited you to Cheeve.it"
    body        :user => user
    content_type  "text/html"
  end
  
end

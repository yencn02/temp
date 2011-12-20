module Notifier
	def send_notification(params)
		type    = params[:type]

		task    = params[:task]
		comment = params[:comment]

		invitor = params[:invitor]
		invited = params[:invited]

		response_user_id = params[:user_id]
		response_friend_id = params[:friend_id]
		response_action = params[:action]

		news_feed_sender = params[:feeder]
		news_feed_recipients = params[:recipients]
		news_feed_id = params[:news_feed_id]
		
		motivation_sender_id = params[:motivator_id];
		motivation_receiver_id = params[:motivated_id];
    motivation_id = params[:motivation_id]
    
    dont_send_email = params[:dont_send_email].nil? ? false : params[:dont_send_email]
      
    notification = nil
		case type
		when 'TaskNotification'
			if task.from_user_id != task.to_user_id #if the task is set to another user
  			notification = Notification.new(:user_id => task.from_user_id, :target_user_id => task.to_user_id)
  			notification.resource = TaskNotification.new(:task_id => task.id)
  			notification.save!
  			
  			if task.assignee.unregistered
  			  Mailer.send_later :deliver_task_to_unregistered_user, task
  			else
  			  notification.send_later :deliver, task
			 end
			end
		when 'ActionOnTaskNotification'
			if task.from_user_id != task.to_user_id #if the task is set to another user
  			notification = Notification.new(:user_id => task.to_user_id, :target_user_id => task.from_user_id)
  			notification.resource = TaskNotification.new(:task_id => task.id)
  			notification.resource.resource = ActionOnTaskNotification.new(:action => task.status.name);
  			notification.save!
        
  			notification.send_later :deliver, task
			end
		when 'AssignerActionOnTaskNotification'
      notification = Notification.new(:user_id => task.assigner.id, :target_user_id => task.assignee.id)
      notification.resource = TaskNotification.new(:task_id => task.id)
      notification.resource.resource = AssignerActionOnTaskNotification.new(:action => task.status.name);
      notification.save!
      
      notification.send_later :deliver, task
		when 'CommentNotification'
			if comment.commentable_type == 'Task'
				task = Task.find(comment.commentable_id)

				if comment.user_id != task.from_user_id
  				notification = Notification.new(:user_id => comment.user_id, :target_user_id => task.from_user_id)
  				notification.resource = CommentNotification.new(:comment_id => comment.id)
  				notification.save!
				end
				if comment.user_id != task.to_user_id
  				notification = Notification.new(:user_id => comment.user_id, :target_user_id => task.to_user_id)
  				notification.resource = CommentNotification.new(:comment_id => comment.id)
  				notification.save!
				end
				
  			notification.send_later :deliver, comment
			end
		when 'NewConnectionNotification'
      if invitor.id != invited.id
        notification = Notification.new(:user_id => invitor.id, :target_user_id => invited.id)
        notification.resource = NewConnectionNotification.new
        notification.save!
        notification.send_later :deliver, current_user
      end

		when 'ConnectionResponseNotification'
			notification = Notification.new(:user_id => response_user_id, :target_user_id => response_friend_id)
			notification.resource = ConnectionResponseNotification.new(:action => response_action)
			notification.save!
			
			notification.send_later :deliver
		when 'NewsFeedNotification'
			#TODO review the scenario whether the assignee should be sent 2 notifications or not
			news_feed_recipients.each do |r|
				notification = Notification.new(:user_id => news_feed_sender, :target_user_id => r)
				notification.resource = NewsFeedNotification.new(:news_feed_id => news_feed_id)
				notification.save!
			end
		when 'MotivationNotification'
		  notification = Notification.new(:user_id => motivation_sender_id, :target_user_id => motivation_receiver_id)
		  notification.resource = MotivationNotification.new(:motivation_id => motivation_id)
		  notification.save!
		when 'ReminderNotification'
      notification = Notification.new(:user_id => task.assigner.id, :target_user_id => task.assignee.id)
      notification.resource = ReminderNotification.new(:task_id => task.id)
      notification.save!
      
      notification.send_later :deliver, task
	  end

    if notification
      notification.notify_opened_browsers
    end
  rescue Exception => e  
    logger.info e.message  
    logger.info e.backtrace.inspect 
	end
end

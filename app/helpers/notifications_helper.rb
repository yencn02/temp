module NotificationsHelper
	# TODO: remove return statements and use rails helpers instead of plain HTML
	# in a case statement you can write html = case ... instead of writing html = many times
  
  def notification_tag(params)
    n = params[:notification];
    events = params[:events];
    
    begin
      case n.resource_type
        when 'TaskNotification'
          if n.resource.resource_type == 'ActionOnTaskNotification'
            icon = "/images/notifications/#{n.resource.resource.action}_action_on_task_notification.png"
            html = <<-STR
                    <div class="notification-header">
                      <div class="notification-img">
                        <img src="#{icon}" alt="Action on Task Notification" />
                      </div>
                      <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                        <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                        said  (I #{n.resource.resource.action}) 
                        regarding this task
                        <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                      </div>
                    </div>
                   STR
          elsif n.resource.resource_type == 'AssignerActionOnTaskNotification'
            icon = "/images/notifications/#{n.resource.resource.action}_assigner_action_on_task_notification.png"
            statement = "marked a task he assigned you as done" if TaskStatus[n.resource.resource.action] == TaskStatus[:did]
            statement = "cancelled a task he assigned you"      if TaskStatus[n.resource.resource.action] == TaskStatus[:cancelled]
            statement = "reassigned a task for you"             if TaskStatus[n.resource.resource.action] == TaskStatus[:waiting]
            html = <<-STR 
                    <div class="notification-header">
                      <div class="notification-img">
                        <img src="#{icon}" alt="Assigner Action on Task Notification" />
                      </div>
                      <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                        <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                        #{statement}
                        <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                      </div>
                    </div>
                   STR
          else
            html = <<-STR
                    <div class="notification-header">
                      <div class="notification-img">
                        <img src="/images/notifications/task_notification.png" alt="Task Notification" />
                      </div>
                      <div class="notification-text #{n.id} #{n.id}" title="#{n.id}" #{events}>
                        <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                        assigned you a new task
                        <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                      </div>
                    </div>
                   STR
          end
          return html
        when 'CommentNotification'
          html = <<-STR
                  <div class="notification-header">
                    <div class="notification-img">
                      <img src="/images/notifications/comment_notification.png" alt="Comment Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                      fired a comment, he said: 
                      "#{Comment.find(n.resource.comment_id).comment}"
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                    </div>
                  </div>
                 STR
          return html       
        when 'NewConnectionNotification'
          html = <<-STR
                  <div class="notification-header"> 
                    <div class="notification-img">
                      <img src="/images/notifications/new_connection_notification.png" alt="New Connection Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                      asked your friendship 
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                    </div>
                  </div>
                 STR
          return html
        when 'ConnectionResponseNotification'
          html = <<-STR
                  <div class="notification-header">
                    <div class="notification-img">
                      <img src="/images/notifications/connection_response_notification.png" alt="Connection Response Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                      #{n.resource.action} your friendship 
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                    </div>
                  </div>
                 STR
          return html
        when 'NewsFeedNotification'
          t = (NewsFeed.find(n.resource.news_feed_id).feed_type == "Task") ? "has been assigned a new task" : "has something new on his/her wall:"
          html = <<-STR
                  <div class="notification-header">
                    <div class="notification-img">
                      <img src="/images/notifications/news_feed_notification.png" alt="News Feed Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                        #{t}          
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                    </div>
                  </div>
                 STR
          return html
        when 'MotivationNotification'
          html = <<-STR 
                  <div class="notification-header">
                    <div class="notification-img">
                      <img src="/images/notifications/motivation_notification.png" alt="Motivation Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                      motivated you to accomplish this task
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span> 
                    </div>
                  </div>
                 STR
          return html
        when 'ReminderNotification'
          html = <<-STR 
                  <div class="notification-header">
                    <div class="notification-img">
                      <img src="/images/notifications/reminder_notification.png" alt="Reminder Notification" />
                    </div>
                    <div class="notification-text #{n.id}" title="#{n.id}" #{events}>
                      <a class="notification-caption" href="/profile/#{n.user_id}">#{User.find(n.user_id).formatted_name}</a> 
                      reminderd you to with a task he assigned you
                      <span class="time-container">#{get_user_friendly_time(n.created_at)}</span>
                    </div>
                  </div>
                 STR
          return html
        else
          html = ''
      end
    rescue
      return ""
    end
  end
      
  def notification_content_tag(params)
  	# TODO: remove ;
    n = params[:notification];
    begin
      case n.resource_type
        when 'TaskNotification'
          task = Task.find(n.resource.task_id)
          render_text = render "shared/task", :task => task, :sep => false, :task_lists => current_user.task_lists
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id} task' title='#{n.resource.task_id}'>
                  #{render_text}
                  </div>
                 STR
          return html
        when 'CommentNotification'
          comment = Comment.find(n.resource.comment_id)
          task = Task.find(comment.commentable_id)
          render_text = render "shared/task", :task => task, :sep => false, :task_lists => current_user.task_lists
          if(comment.commentable_type == "Task")
            html = <<-STR
                    <div class='comment-notification notification-content notification-content-#{n.id} task' title='#{comment.commentable_id}' onmouseover="jQuery(this).find('.comment-container.#{comment.id}').addClass('comment_marked');">
                    #{render_text}
                    </div>
                   STR
          end
          return html        
        when 'NewConnectionNotification'
          friendship = Friendship.find_by_friend_id_and_user_id(n.target_user_id, n.user_id)
          if (friendship.pending?)
            html = <<-STR 
                    <div class='notification-content notification-content-#{n.id} connection-notification' >
                      <div class="accept-friendship">
                      <a href="#{accepted_friendship_path(friendship.user_id)}" onclick="acceptFriendshipRequest(jQuery(this))">Accept</a>
                      </div>
                      /
                      <div class="refuse-friendship">Refuse</div>
                      <br />
                    </div>
                   STR
          else
           html = <<-STR 
                    <div class='notification-content notification-content-#{n.id} connection-notification' >
                      <img src="/images/notifications/#{friendship.accepted? ? 'happy' : 'sad'}.png"> 
                      You #{friendship.accepted? ? 'accepted' : 'refused'} this request
                      <br />
                    </div>
                   STR
          end
          return html
        when 'ConnectionResponseNotification'
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id}' >
                  <br />
                  </div>
                 STR
          return html
        when 'NewsFeedNotification'
          render_text = (NewsFeed.find(n.resource.news_feed_id).feed_type == "Task") ? 
                          (render "shared/task", :task => Task.find(NewsFeed.find(n.resource.news_feed_id).content), :sep => false, :task_lists => current_user.task_lists) : 
                          "#{NewsFeed.find(n.resource.news_feed_id).content}"
          
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id}' >
                    #{render_text}
                    <br />  
                  </div>
                 STR
          return html
        when 'MotivationNotification'
          task = Task.find(Like.find(n.resource.motivation_id).likable_id)
          render_text = render "shared/task", :task => task, :sep => false, :task_lists => current_user.task_lists
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id} motivation-notification' >
                    #{render_text}
                  </div> 
                 STR
          return html
        when 'ReminderNotification'
          task = Task.find(n.resource.task_id)
          render_text = render "shared/task", :task => task, :sep => false, :task_lists => current_user.task_lists
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id} motivation-notification' >
                    #{render_text}
                  </div> 
                 STR
          return html
        when 'MarkTaskAsDoneNotification'
          task = Task.find(n.resource.task_id)
          render_text = render "shared/task", :task => task, :sep => false, :task_lists => current_user.task_lists
          html = <<-STR
                  <div class='notification-content notification-content-#{n.id} motivation-notification' >
                    #{render_text}
                  </div> 
                 STR
          return html
        else 
          html = ''
      end
    rescue
      return ""
    end
  end
end

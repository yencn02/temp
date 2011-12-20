module NewsFeedsHelper
	# TODO: remove return statements, semi-colons and use rails helpers instead of plain HTML
	# in a case statement you can write html = case ... instead of writing html = many times

  def news_feed_tag(params)
    news_feed = params[:news_feed]
    user = User.find(news_feed.user_id)
    
    links = <<-STR
              <span>#{link_to "Comment (#{news_feed.comments.count})", "", :class => "notes"}</span>
              #{render("commentable_motivatable/motivate", :motivatable => news_feed)}
            STR
    
    comments_section = "#{render('commentable_motivatable/comments', :commentable => news_feed)}"
    begin
      case news_feed.feed_type
        when 'Status'
          html = <<-STR
                 <div class="newsfeed-item status #{news_feed.id}" data-id="#{news_feed.id}" data-type="'NewsFeed'">
                  <div class="main-content">
                    <div class="status-icon"></div>
                    <div class="avatar">
                      <img src="#{profile_avatar_path(user.user_info.id, 'thumb')}" alt="#{user.name}" height="64px" width="64px"/>
                    </div>
                    <div class="news-feed-content">
                      <a class="news-feed-user" href="/profile/#{user.id}">#{user.name.formatted_titleize} #{'(you)' if user.id == current_user.id} </a>
                      changed #{user.id == current_user.id ? "your" : "his/her" } status to:
                      <br />
                      #{news_feed.content}
                    </div>
                    <br />
                  </div>
                  <div class="extra-content more">
                    <span class="time-container">#{get_user_friendly_time(news_feed.created_at)}</span>
                    #{links}
                    #{comments_section}
                  </div>
                 </div>
                 STR
          return html;
        when 'Question'
          html = <<-STR
                 <div class="newsfeed-item status #{news_feed.id}" data-id="#{news_feed.id}">
                  <div class="main-content">
                    <div class="question-icon"></div>
                    <div class="avatar">
                      <img src="#{profile_avatar_path(user.user_info.id, 'thumb')}" alt="#{user.name}" height="64px" width="64px"/>
                    </div>
                    <div class="news-feed-content">
                      <a class="news-feed-user" href="/profile/#{user.id}">#{user.name.formatted_titleize} #{'(you)' if user.id == current_user.id} </a>
                      asked a question:
                      <br />
                      #{news_feed.content}
                    </div>
                    <br />
                  </div>
                  <div class="extra-content more">
                    <span class="time-container">#{get_user_friendly_time(news_feed.created_at)}</span>
                    #{links}
                    #{comments_section}
                  </div>
                 </div>
                 STR
          return html;  
        when 'Link'
          html = <<-STR
                 <div class="newsfeed-item status #{news_feed.id}" data-id="#{news_feed.id}">
                   <div class="main-content">
                    <div class="link-icon"></div>
                    <div class="avatar">
                      <img src="#{profile_avatar_path(user.user_info.id, 'thumb')}" alt="#{user.name}" height="64px" width="64px"/>
                    </div>
                    <div class="news-feed-content">
                      <a class="news-feed-user" href="/profile/#{user.id}">#{user.name.formatted_titleize} #{'(you)' if user.id == current_user.id} </a>
                      sent a link:
                      <br />
                      <a target='_blank' href='http://#{news_feed.content}'>#{news_feed.content}</a>
                    </div>
                    <br />
                  </div>
                  <div class="extra-content more">
                    <span class="time-container">#{get_user_friendly_time(news_feed.created_at)}</span>
                    #{links}
                    #{comments_section}
                  </div>
                 </div>
                 STR
          return html
        when 'Task'
          rendered_task = render "shared/task", :task => Task.find(news_feed.content.to_i), :sep => false, :task_lists => current_user.task_lists
          html = <<-STR
                 <div class="newsfeed-item status #{news_feed.id}" data-id="#{news_feed.id}">
                   <div class="main-content">
                    #{rendered_task}
                   </div>
                 </div>
                 STR
          return html
      end
    rescue
      return ""
    end
  end
  
end

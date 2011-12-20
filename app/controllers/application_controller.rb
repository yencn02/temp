# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
    
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  prepend_before_filter :clean_authenticity_token
  
  before_filter :get_count_of_unvisited_notifications
  before_filter :build_new_task
  before_filter :set_title  
  
  layout :layout_by_resource   
  
  def authenticate_user_with_unregistered!
    current_user.unregistered ? true : authenticate_user_without_unregistered!
  end
  alias_method_chain :authenticate_user!, :unregistered
  
  def current_user_with_unregistered
    session[:unregistered_user_id] ? User.find(session[:unregistered_user_id]) : current_user_without_unregistered
  end
  alias_method_chain :current_user, :unregistered

  def set_title
    # TODO MIGRATION
    #@template.title("Cheeveit", false)
  end
  
  #TODO use Warden::Manager.after_logout
  def unregistered_sign_out
    session[:unregistered_user_id] = nil        
    
    redirect_to root_url
  end  

  protected  
    
    def layout_by_resource
      if devise_controller? && resource_name == :user && request.params["action"] == "new"
        "registrations"
      else
        "application"
      end
    end
    
    def me?(user)
      current_user == user
    end
    
    
    def load_filters
      @filters = (params[:filters].blank? ? {} : params[:filters])
      @from_me = true if @filters[:tasks] == "from_me"
      @for_me = true if @filters[:tasks] == "for_me"
      @my_hive = true if @filters[:tasks] == "news_feeds"
      @notifications = true if @filters[:tasks] == "notifications"
      @task_lists = current_user.task_lists
      @task_list = current_user.task_lists.find_by_id(@filters[:task_list_id])
    end
    
    def list_of_friends_images_names
      #prepare list of friends images
      @friends_images = []
      current_user.friends_ids.each do |f_id|
        friend_user_info_id = User.find(f_id).user_info.id
        @friends_images << profile_avatar_path(friend_user_info_id, :medium);
      end
      @all_friends_images = @friends_images.join(",")
    end
    
    def build_new_task
      @task = current_user.from_me.build if current_user
    end
  
    def get_count_of_unvisited_notifications
      if current_user 
        @all_unvisited_notifications_count = Notification.for_user(current_user.id).unvisited.grouped_count.count
      end
    end
    
    def calculate_tags
      filters = session[:filters]
      if @from_me
        tasks = current_user.rsend(filters[:tasks], filters[:status])
      else
        #FIND_BY_ID RATHER THAN FIND TO MAKE SURE IT DOESN'T THROW AN EXCEPTION IN CASE ID = 0
        task_list = TaskList.find_by_id(filters[:task_list_id])        
        tasks = current_user.rsend(filters[:tasks], filters[:status], [:task_list, task_list])
      end
      
      Tag.with_ids(Tagging.with_taggables(tasks.map{|t| t.id}).map{|tg| tg.tag_id}).join(',')
    end
      
    def is_email? txt
      /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i.match(txt)
    end
    
    def get_full_url(base_url)
      return base_url.chop + request.path + get_params_as_url_friendly
    end
    
    def get_params_as_url_friendly
      count = 0
      param_size = request.query_parameters.size
      parameters = ""
      
      for param in request.query_parameters
        parameter = "#{param[0]}=#{param[1]}"
        
        if count == 0
          parameter = "?#{parameter}"
        else
          parameter = "&#{parameter}"
        end
        
        count += 1
        parameters += parameter
      end
      
      return parameters
    end
    
    def flush_external_actions_from_session
      session[:external_action] = nil
      session[:user_id] = nil
      session[:task_id] = nil
      session[:user_action] = nil
    end
    
    def clean_authenticity_token
      token = params[request_forgery_protection_token]
       
      params[request_forgery_protection_token] = CGI::unescape(token) if token
    end
  
end

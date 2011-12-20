class HomeController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :unregistered_home, :external_action]
  
  def index
    #TODO, the same code snippet exists in tasks_controller.unregistered_user_action
    if(params[:unregistered_user_id])
      sign_out(current_user) if current_user
            
      reset_session
      session[:unregistered_user_id] = params[:unregistered_user_id]
    end
    
    @external_action = session[:external_action]
    
    if user_signed_in? or User.user_exists_with_security_code?(params[:unregistered_user_id], params[:security_code])
      if @external_action == 'registered_action'
        redirect_to registered_user_action_url(session[:user_id],
                                               session[:task_id],
                                               session[:user_action])
      else
        home
      end
    else
      render :action => "index", :layout => "application"      
    end
  end
  
  def external_action
    session[:external_action] = params[:external_action]
    session[:user_id] = params[:user_id]
    session[:task_id] = params[:task_id]
    session[:user_action] = params[:user_action]
    
    index
  end
    
  def show_registration_required
  end
  
  def user_updates
    render :js => ""
  end
  
  def fetch_tags
    tags = calculate_tags
    render :text => tags
  end
  
  private
  
  def home
    flush_external_actions_from_session
    
    if current_user.unregistered
      session[:filters] = {:task_list_id=>"0", :tasks=>"for_me", :tags=>"", :status=>"every"}
    else
      session[:filters] = {:task_list_id=>"0", :tasks=>"for_me", :tags=>"", :status=>"pending"}
    end
    
    @task_lists = current_user.task_lists
    @task_list = nil
    
    #TODO MIGRATION, change the line to be "@tasks = current_user.for_me.pending " and fix
    @tasks = current_user.for_me 
      
    @for_me = true    
    @task_statuses = TaskStatus.all
    
    @all_friends_images = list_of_friends_images_names
    
    @filter_tags = []
    @tags = calculate_tags

    @pending_friends = current_user.pending_friends
    @user_task_lists = current_user.task_lists
    
    @after_load_accept_friendship = params[:accept_friendship]
    if @after_load_accept_friendship == 'accept_friendship'
      @after_load_accept_friend_id = params[:initiator_id].nil? ? -1 : params[:initiator_id]
    end
    
    unless current_user.unregistered
      render :action => :home
    else
      render :action => :unregistered_home, :layout => "unregistered_home"
    end
  end
  
end

require 'contacts'
require 'users_helper'

class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => ['change_spam_state']
  before_filter :verify_authenticity_token
  
  before_filter :get_unvisited_notifications_count, :only => ['show', 'edit']
    
  layout "home"
  
  include ApplicationHelper
  
  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.xml { render :xml => {:status => 0, 'user_info' => @user }.to_xml(:root => :result) }
      format.html
    end
    
  rescue Exception => e
    
    respond_to do |format|
      format.xml  { render :xml => {:status => 1, :message => e.message }.to_xml(:root => :result)}
      format.html { render :status => 404 } 
    end
  end
  
  def edit
  end
  
  def email_available
    if User.find_by_email(params[:user][:email])
      render :text => '"email has already been taken"'
    else
      render :text => "true"
    end
  end
  
  def username_available
    if User.find_by_username(params[:user][:username])
      render :text => '"username has already been taken"'
    else
      render :text => "true"
    end
  end
  
  def auto_complete_friends
    q = params[:q].downcase
    users = current_user.auto_complete_friends(q, 20)
    
    users_list = users.map do |u| 
      auto_complete_row_data(u).join "|"       
    end
    
    render :text => users_list.join("\n"), :content_type => 'text/html' 
    
  end
  
  def accessible_task_lists
    if params[:uid].to_i == current_user.id || params[:uid] == 'yourself'
      @task_lists = current_user.task_lists
    elsif params[:uid] and params[:uid] != 'other'
      #TODO discuss, Create a "named scope" called accepted_friend, which takes "id"
      user = User.find params[:uid].to_i
      unless user.nil?
        if current_user.friendship_exists_with? user #if user and friend
          @task_lists = user.task_lists.accessible_for current_user 
        else #if user but not friend
          @task_lists = user.default_task_lists
        end
      else #if not a user at all
        @task_lists = create_fake_task_lists
      end
    else
      @task_lists = create_fake_task_lists
    end
    
    render :js => "updateTaskListsSelect(\"#{@template.task_lists_options_for_select(@task_lists)}\");"             
  end
  
  def create_fake_task_lists
    StandardTaskList.all
  end
    
  def change_spam_state
    reportee = User.find(params[:reportee_id])
    state = params[:state]
    if state == "true"
      current_user.mark_user_as_spam(reportee)
    else
      current_user.mark_user_as_not_spam(reportee)
    end
  end
  
  def does_user_exist
    @user = User.send "find_by_#{params[:type]}", params[:value]
    @user
  end
  
  #-FOR TESTING PURPOSES ONLY, TO BE DELETED ON QA REQUEST
  def kill_me_and_sign_out
    current_user.destroy
    render :js => "location.href = location.protocol + '//' + location.host"
  end
  
  protected
  def get_unvisited_notifications_count
    @all_unvisited_notifications_count = Notification.for_user(current_user.id).unvisited.grouped_count.count
  end

end

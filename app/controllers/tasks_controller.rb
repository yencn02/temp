class TasksController < ApplicationController
  include Notifier
  before_filter :authenticate_user!, :except => [:unregistered_user_action]
  before_filter :load_filters, :except => [:unregistered_user_action, :add_tag_to, :remove_tag_from]
  before_filter :create_task, :only => [:create]

  # GET /tasks
  # GET /tasks.xml
  def index
    @filters[:status] = @filters[:status].nil? ? "pending" : @filters[:status]
    raise Exception.new("filters['tasks'] isn't supplied") unless ["for_me", "from_me", "my_hives"].include?(@filters[:tasks])
    raise Exception.new("filters['status'] isn't supplied") unless ["every", "pending"].include?(@filters[:status]) || TaskStatus[@filters[:status].to_sym]
    session[:filters] = @filters

    if @from_me
      @tasks = current_user.rsend(@filters[:tasks], @filters[:status])
    else
      @tasks = current_user.rsend(@filters[:tasks], @filters[:status], [:task_list, @task_list])
    end
    
    @filter_tags = []
    if @filters[:tags] && !@filters[:tags].blank?
      @filter_tags = @filters[:tags].split(',') ? @filters[:tags].split(',') : []
      tags_ids = Tag.with_names(@filter_tags)
      tasks = Task.with_id_in(@tasks.map{|t| t.id})
      @tasks = tasks.with_taggings(Tagging.with_tag_ids(tags_ids.map{|t| t.id}).map{|tg| tg.taggable_id})
    end
    
    @tags = calculate_tags
    
    page = @filters[:page].nil? ? 1 : @filters[:page]
    @tasks = @tasks.paginate(:page => page, :per_page => 5)
    
    @task_statuses = TaskStatus.all
      
    respond_to do |format|
      format.xml { render :xml => {:status => 0, 'tasks' => @tasks }.to_xml(:root => :result) }
      format.js
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = Task.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    @is_reassign = (params[:is_reassign] == 'true')
    @with_cancel = (params[:with_cancel] == 'true')
    @clone_task = Task.find params[:clone_task] if @is_reassign
    @task.save
    @tags = calculate_tags
    render
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update    
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Task was successfully updated.'
        format.html { redirect_to(@task) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    if me?(@task.assigner) 
      @task.destroy
    else
      @task = nil
    end

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.js
    end
  end
  
  #handles assigner remind action
  #remind action is called externally from emails through registered_user_action
  #as well as internally from cheeve.it, that's why we need to decide
  #which ID to use
  def remind(task_id=nil)
    id = task_id.nil? ? params[:id] : task_id
    
    @task = Task.find(id)
    @task.reminders = @task.reminders + 1
    @task.last_reminder_at = Time.now
    @task.save
    send_notification({:type => 'ReminderNotification', :task => @task})
  end

  #handles the actions on a task (will/did/cant)
  def status
    @assigner_action = (params[:assigner_action] == "true")
    @render_undo_msg = (params[:render_undo_msg] == "true") #determines wheather the undo message will be rendered or not 
    
    if @assigner_action
      @task = current_user.from_me.find params[:id]
      @old_status = @task.status 
    else
      @assigner_action = false;
      @task = current_user.for_me.find params[:id]
      @old_status = @task.status
    end

    @task.change_status params[:status]
    
    @isundo = (params[:undo] == "true")
    @tags = calculate_tags
    
    respond_to do |format|
      format.js do
        if params[:save] and params[:save] == 'true' and @task.save
      	  @task.notify_on_status_change @assigner_action

      	  render :text => ''
      	elsif !@task.errors.empty?
          render :js => "alert('cannot apply action due to errors')"
        else
          render :partial => 'shared/change_task_status'
      	end
      end
    end
  end
  
  #handles the, reassign to yourself and reassitn to assignee (receipient) action
  def reassign_task
    @isundo = (params[:undo] == "true")
    @task = Task.find params[:id]
    if params[:save] and params[:save] == 'true'
      @new_task = Task.new :description  => @task.description,
                           :assigner     => current_user,
                           :task_list    => current_user.task_lists.first, #the general task list
                           :private_task => @task.private_task
  
      if params[:target_user] == "assignee"
        @new_task.status = TaskStatus[:waiting] 
        @new_task.assignee = @task.assignee
      else #reassign to yourself
        @new_task.status = TaskStatus[:will] 
        @new_task.assignee = current_user
      end
      
      @new_task.save
      unless params[:with_comments] == "false"
        @task.comments.each do |comment|
          Comment.create  :title            => comment.title,
                          :comment          => comment.comment,
                          :commentable_id   => @new_task.id,
                          :commentable_type => @new_task.type.to_s,
                          :user             => comment.user,
                          :dont_notify      => true
        end
      end
    end #end if
      
    respond_to do |format|
      format.js do        
        if params[:save] and params[:save] == 'true'
          @task.notify_on_reassign params[:target_user]
          render :text => ''
        elsif !@task.errors.empty?
          render :js => "alert('cannot apply action due to errors')"
        else
          render
        end #end if
      end #end format do
    end #end reposnd do
  end
  
  #handles assignee change task list action
  def change_task_list
    @task = current_user.for_me.find params[:id]
    @task.task_list = current_user.task_lists.find params[:new_task_list_id]
    
    @all_list_selected = (params[:task_list_id].to_i == 0)

    if @task.save
      respond_to :js
    else
      render :js => 'alert("Cant change task list for task.");'
    end
  end
  
  #-Action from mail (from a registered user)
  def registered_user_action
    flush_external_actions_from_session
    
    respond_to do |format|
      format.html { 
        task = Task.find(params[:task_id])
        if params[:user_action] == 'remind'
          remind params[:task_id]
        else
          task.change_status params[:user_action]
          task.save
          current_user.mark_user_as_not_spam(task.assigner)
        end
        redirect_to(root_url) 
      }
    end
  end
  
  # - Action from mail (from an unregistered user)
  def unregistered_user_action
    if(params[:unregistered_user_id])
      sign_out(current_user) if current_user
      
      reset_session
      session[:unregistered_user_id] = params[:unregistered_user_id]
    end
    
    respond_to do |format|
      format.html { 
        task = Task.find(params[:task_id])
        task.change_status params[:status]
        task.save
        
        current_user.mark_user_as_not_spam(task.assigner)
        redirect_to(unregistered_home_url(task.assignee.id, task.assignee.security_code.security_code)) 
      }
    end
  end
  
  def toggle_privacy
    @task = current_user.for_me.find(params[:id])
    @task.private_task = !@task.private_task
    @task.save
    render :nothing => true
  end
  
  def add_tag_to
    @task = Task.find(params[:id])
    @task.add_multiple_tags(params[:tag])
    @task.save
    
    @tags = calculate_tags
  end
    
  def remove_tag_from
    @tag = params[:tag]
    @task = Task.find(params[:id])
    @task.tag_list.remove(@tag)
    @task.save
    
    @tags = calculate_tags
  end
  
  private
  
  def create_task
    task = params[:task]
    
    #create the task --------------------------------------------------------------
    @task = Task.new(:description => task[:description], :private_task => task[:private_task])
    @task.assigner = current_user
    @task.status = TaskStatus[:waiting] #initially, may change later in task is assigned to yourself
    #------------------------------------------------------------------------------
    
    #add tags to the task ---------------------------------------------------------
    #TODO: try nested_atributes ---------------------------------------------------
    if params[:item]
      tags = params[:item][:tags] ? params[:item][:tags].join(',') : ''
      @task.add_multiple_tags(tags)
    end
    #------------------------------------------------------------------------------
    
    #Search for the user in db, if exists; consider -------------------------------
    #if email inserted instead of a user, find the user if exists
    if task[:to_user_id] == 'other' && is_email?(task[:to_user_name])
      user = User.find_by_email(task[:to_user_name])
      if me?(user)
        task[:to_user_id] = 'yourself'
        task[:to_user_name] = current_user.name
      else
        unless user.nil?
          task[:to_user_id] = user.id
          task[:to_user_name] = user.name
        end
      end
    # if task is assinged to a contact (maybe have an account on cheeve it, may not)
    elsif task[:to_user_id] == 'other' && is_email?(task[:to_user_email])
      user = User.find_by_email(task[:to_user_email])
      unless user
        user = User.create_unregistered_user(task[:to_user_email])
      end
      task[:to_user_id] = user.id
      task[:to_user_name] = user.name
    end
    #------------------------------------------------------------------------------
    
    #Cases of to user (yourself, existing user, non-existing user) ----------------
    # task assigned to myself
    if task[:to_user_id] == "yourself" || task[:to_user_id].to_i == current_user.id
      @task.assignee = current_user
      @task.status = TaskStatus[:will]
      @task.task_list = current_user.task_lists.find task[:task_list_id]
    # if task is assinged to an existing user (maybe a friend, a non-friend or an unregistered user)
    elsif task[:to_user_id].to_i > 0
      user = current_user.accepted_friends.find(:first, :conditions => {:id => task[:to_user_id]})
      if user # task assigned to a friend
        @task.assignee = user
        if user.task_lists.find task[:task_list_id]
          @task.task_list = user.task_lists.accessible_for(current_user).find(task[:task_list_id]) # must check if user has granted this access to the task list
        else
          @task.task_list = user.default_task_list
        end
      else # non-friend user or unregistered but exists in the db
        user = User.find_by_id task[:to_user_id]
        @task.assignee = user
        @task.task_list = user.task_lists.find task[:task_list_id]
      end
    # if task is assinged to an unregistered user that doesn't exist in the system
    elsif task[:to_user_id] == 'other' && is_email?(task[:to_user_name])
      user = User.create_unregistered_user(task[:to_user_name])
      @task.assignee = user
      @task.task_list = user.task_lists[task[:task_list_id].to_i - 1] #-1 to because array access is 0-based
    else
      puts ".......................................NO CONDITION HOLDS, THIS IS AN ERROR"
    end
    #------------------------------------------------------------------------------
  end
end

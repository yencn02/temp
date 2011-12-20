class TaskListsController < ApplicationController
  before_filter :authenticate_user!
  
  layout false
  
  # GET /task_lists
  # GET /task_lists.xml
  def index
    @task_lists = current_user.task_lists

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /task_lists/1
  # GET /task_lists/1.xml
  def show
    @task_list = current_user.task_lists.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /task_lists/new
  # GET /task_lists/new.xml
  def new
    @task_list = current_user.task_lists.build
    
    # TODO: helper method not controller code
    #prepare list of list icons
    @list_images = []
    Dir.foreach("#{RAILS_ROOT}/public/images/list_icons") do |entry|
      if(/.*\.(png|jpg|gif)/.match(entry))
        @list_images << entry
      end
    end
    @list_images.sort!
    
    #prepare list of friends
    @friends = []
    current_user.friends_ids.each do |f_id|
      @friends << User.find(f_id)
    end
    
    @all_friends = current_user.friends_ids.join(",")
    
    respond_to do |format|
      format.html # new.html.erb
      format.js
    end
  end

  # GET /task_lists/1/edit
  def edit
    @task_list = current_user.task_lists.find(params[:id])
    
    # TODO: helper method not controller code
    #prepare list of list icons
    @list_images = []
    Dir.foreach("#{RAILS_ROOT}/public/images/list_icons") do |entry|
      if(/.*\.(png|jpg|gif)/.match(entry))
        @list_images << entry
      end
    end
    @list_images.sort!
    
    # TODO: use inject
    #prepare list of friends
    @friends = []
    current_user.friends_ids.each do |f_id|
      @friends << User.find(f_id)
    end
    
    # TODO: use inject
    #prepare list of already connected friends ids
    @already_connected_friend = []
    @task_list.connections.each do |c|
      @already_connected_friend << c.user_id
    end
  end

  # POST /task_lists
  # POST /task_lists.xml
  def create
  	# TODO: remove ()
    @task_list = current_user.task_lists.new()
    @task_list.title = params[:task_list][:title]
    @task_list.icon_name = params[:task_list][:icon_name]

    respond_to do |format|
      if @task_list.save
        flash[:notice] = 'TaskList was successfully created.'
        # register friends in this task list (add friends to connections)
        params[:task_list][:selected_friends_new].split(",").each do |uid|
          @task_list.connections.create(:user_id => uid)
        end
        # format.html { redirect_to(root_url) }
        format.js
      else
        flash[:error] = @task_list.errors.full_messages.to_sentence
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  # PUT /task_lists/1
  # PUT /task_lists/1.xml
  def update
    @task_list = current_user.task_lists.find(params[:id])
    # @task_list_selected = (@task_list.id == params[:filters][:task_list_id])
    
    respond_to do |format|
      if @task_list.editable
        @task_list.update_attributes({:title=>params[:task_list][:title], :icon_name=>params[:task_list][:icon_name]})
        @task_list.save
      end
      flash[:notice] = 'TaskList was successfully updated.'
      # update friends
      @task_list.destroy_all_connections
      params[:task_list][:selected_friends_edit].split(",").each do |uid|
        @task_list.connections.create(:user_id => uid)
      end
      format.html { redirect_to(root_url) }
      format.js
    end
  end

  # DELETE /task_lists/1
  # DELETE /task_lists/1.xml
  def destroy
    @task_list = current_user.task_lists.find(params[:id])
    @task_list.destroy

    respond_to do |format|
      format.html { redirect_to(root_url) }
      format.js
    end
  end
  
  def edit_connections
    @task_list = current_user.task_lists.find(params[:id])
    @task_list.destroy_all_connections
    
    params[:uids].split(",").each do |uid|
      @task_list.connections.create(:user_id => uid)
    end
    
    respond_to do |format|
      format.js { render :js => "$j.colorbox.close();" }
    end
  end
  
end

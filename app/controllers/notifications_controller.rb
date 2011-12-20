class NotificationsController < ApplicationController
  before_filter :load_filters
  
  def index
    page = @filters[:page].nil? ? 1 : @filters[:page]
    @all_notifications = Notification.for_user(current_user.id).ordered_by_creation_date
    @all_unvisited_notifications_count = 0
    @all_unvisited_notifications_ids = @all_notifications.unvisited.map {|un| "#{un.id},"}
    @all_notifications_ids           = @all_notifications.map {|vn| "#{vn.id},"}
    @all_notifications.unvisited.update_all("visited = '1'")
    
    @all_notifications = @all_notifications.paginate(:page => page, :per_page => 10)
    @notifications = true
  end
  
  def change_task_status
    @task = Task.find(params[:task_id])
    @old_status = @task.status
    @task.change_status(params[:status])
    @isundo = (params[:undo] == "true")
    @notifications = true
    
    respond_to do |format|
      format.js do
      	# TODO: user else instead of return
        unless @task.save
          render :js => 'alert("Cant change task status.");'
          return          
        end
        render :partial => "shared/change_task_status"
      end
    end
  end
  
  def juggernaut_me
    render :juggernaut do |page|
    end
  end
  
end

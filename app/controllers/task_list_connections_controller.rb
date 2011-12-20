class TaskListConnectionsController < ApplicationController
  before_filter :authenticate_user!
  
  
  def create
    @conn = current_user.task_lists.find(params[:tlid]).connections.new(:user_id => params[:fid])
    
    @user, @friend = current_user, @conn.editor
    
    respond_to do |format|
      format.js do
        unless @conn.save
          render :js => "alert(\"#{@conn.errors.full_messages}\")" 
        end
      end          
    end      
  end
  
  def destroy
    @conn = current_user.task_lists.find(params[:id]).connections.find_by_user_id(params[:fid]) || raise(ActiveRecord::RecordNotFound)
    @conn.destroy

    @user, @friend = current_user, @conn.editor
    
    respond_to :js        
  end
  
end

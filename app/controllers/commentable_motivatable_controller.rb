class CommentableMotivatableController < ApplicationController
  include Notifier
  
  def create_comment
    @commentable = params[:commentable_type] == 'Task' ? current_user.tasks.find(params[:commentable_id]) : NewsFeed.find(params[:commentable_id]) 
    @comment = @commentable.comments.build(params[:comment])
    @comment.user = current_user
    
    respond_to do |format|
      format.js do
        render :js => 'alert("Cant create comment")' unless @comment.save
      end
    end
  end
  
  def destroy_comment
    @commentable = params[:commentable_type] == 'Task' ? current_user.tasks.find(params[:commentable_id]) : NewsFeed.find(params[:commentable_id])
    @comment = @commentable.comments.find(params[:comment_id])
    
    respond_to do |format|
      format.js do
        render :js => 'alert("Cant delete comment")' unless @comment.delete
      end
    end
  end

  #alternate motivation for current user (if liked then unlike, if unliked then like)
  def motivation_action
    @motivatable = params[:motivatable_type] == 'Task' ? Task.find(params[:motivatable_id]) : NewsFeed.find(params[:motivatable_id]) 
    
    if @motivatable.liked_by_user?(current_user) #liked by current user, so, let's unlike it!
      @motivation = Like.find_by_user_id_and_likable_id_and_likable_type(current_user.id,
                                                                       params[:motivatable_id], 
                                                                       params[:motivatable_type])
      @motivation.destroy
      @new_motivation_action = 'motivate'
    else #not liked by current user, so, let's like it!
      @motivation = Like.create(:user_id => current_user.id, :likable_id => @motivatable.id, :likable_type => @motivatable.class.to_s)
      @new_motivation_action = 'unmotivate'
    end

    @motivatable.reload
    
    motivated_id = params[:motivatable_type] == 'Task' ? Task.find(params[:motivatable_id]).assignee.id : NewsFeed.find(params[:motivatable_id]).user.id
    send_notification({:type => "MotivationNotification",:motivator_id => current_user.id, :motivated_id => motivated_id,
                       :motivation_id => @motivation.id, :dont_send_emai => true})
    respond_to do |format|
      format.js
    end
  end
  
end

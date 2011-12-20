class ImagesController < ApplicationController
  before_filter :authenticate_user!
  
  def avatar
  	# TODO: use a varialbe to store the style then call send_file once
  	# or .path((params[:style] || "thumb").to_sym)
    if params[:style]
      send_file current_user.avatar.path(params[:style].to_sym)
    else
      send_file current_user.avatar.path(:thumb)
    end
  end
  
  def task_list
    @task_list = current_user.task_lists.find(params[:id])
    # TODO: use a varialbe to store the style then call send_file once
    # or .path((params[:style] || "small").to_sym)
    if params[:style]
      send_file @task_list.photo.path(params[:style].to_sym)
    else
      send_file @task_list.photo.path(:small)
    end
  rescue ActiveRecord::RecordNotFound
    send_file TaskList.new.photo(:small)
  end  
  
end

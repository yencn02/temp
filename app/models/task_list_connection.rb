class TaskListConnection < ActiveRecord::Base
  
  belongs_to :task_list
  belongs_to :editor, :class_name =>  "User", :foreign_key => "user_id"
  
  validates_presence_of :task_list_id, :user_id
  validates_uniqueness_of :task_list_id, :scope => :user_id  
  
  scope :granted_by, lambda { |user| {:conditions => {:task_list_id => user.task_list_ids}} }
  
end

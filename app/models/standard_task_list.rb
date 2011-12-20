# created for manipulating task_lists table only (no other purpose is obvious till now)
class StandardTaskList < ActiveRecord::Base
  def self.default_task_list_title
    StandardTaskList.find_by_default(true).title
  end
  
  def self.general_task_list_title
    "General"
  end
end

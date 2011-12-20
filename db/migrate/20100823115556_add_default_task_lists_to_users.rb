class AddDefaultTaskListsToUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.task_lists.destroy_all
      user.add_default_task_lists
    end
  end

  def self.down    
  end
end

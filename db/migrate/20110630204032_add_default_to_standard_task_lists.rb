class AddDefaultToStandardTaskLists < ActiveRecord::Migration
  def self.up
    add_column :standard_task_lists, :default, :boolean, :default => false
    
    general = StandardTaskList.find_by_title('General')
    general.default = true
    general.save!
    
  end

  def self.down
    remove_column :standard_task_lists, :default
  end
end

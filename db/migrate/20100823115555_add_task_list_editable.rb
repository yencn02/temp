class AddTaskListEditable < ActiveRecord::Migration
  def self.up
    add_column :task_lists, :editable, :boolean, :default => true
  end

  def self.down
    remove_column :task_lists, :editable    
  end
end

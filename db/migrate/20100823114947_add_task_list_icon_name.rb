class AddTaskListIconName < ActiveRecord::Migration
  def self.up
    remove_column :task_lists, :photo_file_name
    remove_column :task_lists, :photo_content_type
    remove_column :task_lists, :photo_file_size
    
    add_column :task_lists, :icon_name, :string, :null => false
  end

  def self.down
    remove_column :task_lists, :icon_name
    
    add_column :task_lists, :photo_file_name, :string
    add_column :task_lists, :photo_content_type, :string
    add_column :task_lists, :photo_file_size, :string    
  end
end

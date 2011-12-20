class AddTaskListPhoto < ActiveRecord::Migration
  def self.up
    add_column :task_lists, :photo_file_name, :string
    add_column :task_lists, :photo_content_type, :string
    add_column :task_lists, :photo_file_size, :string
  end

  def self.down
    remove_column :task_lists, :photo_file_name, :string
    remove_column :task_lists, :photo_content_type, :string
    remove_column :task_lists, :photo_file_size, :string
  end
end

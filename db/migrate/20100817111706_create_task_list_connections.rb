class CreateTaskListConnections < ActiveRecord::Migration
  def self.up
    create_table :task_list_connections do |t|
      t.integer :user_id, :null => false
      t.integer :task_list_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :task_list_connections
  end
end

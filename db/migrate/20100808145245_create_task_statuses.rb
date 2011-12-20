class CreateTaskStatuses < ActiveRecord::Migration
  def self.up
    create_table :task_statuses do |t|
      t.column :name, :string

      t.timestamps
    end
    
    add_column :tasks, :status_id, :integer
  end

  def self.down
    drop_table :task_statuses
    remove_column :tasks, :status_id    
  end
end

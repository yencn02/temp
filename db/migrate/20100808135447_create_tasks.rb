class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.text :description
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :task_list_id
      t.boolean :private_task

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end

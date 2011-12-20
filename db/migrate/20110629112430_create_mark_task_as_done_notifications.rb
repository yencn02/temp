class CreateMarkTaskAsDoneNotifications < ActiveRecord::Migration
  def self.up
    create_table :mark_task_as_done_notifications do |t|
      t.integer :task_id
    end
  end

  def self.down
    drop_table :mark_task_as_done_notifications
  end
end

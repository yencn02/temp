class CreateAdminActionOnTaskNotifications < ActiveRecord::Migration
  def self.up
    drop_table :mark_task_as_done_notifications
    
    create_table :assigner_action_on_task_notifications do |t|
      t.string :action    
    end
  end

  def self.down
    drop_table :assigner_action_on_task_notifications
  end
end

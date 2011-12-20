class CreateReminderNotifications < ActiveRecord::Migration
  def self.up
    create_table :reminder_notifications do |t|
      t.integer :task_id
    end
  end

  def self.down
  end
end

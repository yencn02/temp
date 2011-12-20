class AddReminderToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :reminders, :integer, :default => 0
    add_column :tasks, :last_reminder_at, :timestamp
  end

  def self.down
    remove_column :tasks, :reminders
    remove_column :tasks, :last_reminder_at
  end
end

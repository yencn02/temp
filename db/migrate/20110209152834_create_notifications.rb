class CreateNotifications < ActiveRecord::Migration
  def self.up
		create_table :notifications do |t|
			t.integer :user_id
      t.integer :target_user_id
      
			t.integer :resource_id
			t.string :resource_type

			t.timestamps
		end

		create_table :task_notifications do |t|
			t.integer :task_id

			t.integer :resource_id
			t.string :resource_type
		end

		create_table :comment_notifications do |t|
			t.integer :comment_id

			t.integer :resource_id
			t.string :resource_type
		end

		create_table :connection_response_notifications do |t|
			t.string :action
		end

		create_table :new_connection_notifications do |t|
		end

		create_table :post_notifications do |t|
			t.integer :post_id
		end

		create_table :action_on_task_notifications do |t|
			t.string :action		
		end

  end

  def self.down
		drop_table :action_on_task_notifications
		drop_table :post_notifications
		drop_table :new_connection_notifications
		drop_table :connection_response_notifications
		drop_table :comment_notifications
		drop_table :task_notifications
		drop_table :notifications
  end
end

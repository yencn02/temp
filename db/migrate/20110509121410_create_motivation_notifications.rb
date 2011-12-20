class CreateMotivationNotifications < ActiveRecord::Migration
  def self.up
  	create_table :motivation_notifications do |t|
  	  t.integer :motivation_id
  	  t.integer :resource_id
      t.string :resource_type
  	end
  end

  def self.down
  	drop_table :motivation_notifications
  end
end

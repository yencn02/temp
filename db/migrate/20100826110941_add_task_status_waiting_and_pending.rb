class AddTaskStatusWaitingAndPending < ActiveRecord::Migration
  def self.up
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.create :name => "waiting"
    TaskStatus.create :name => "pending"
    TaskStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.find_by_name("waiting").destroy
    TaskStatus.find_by_name("pending").destroy
    TaskStatus.enumeration_model_updates_permitted = false
  end
end

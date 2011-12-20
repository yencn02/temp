class UpdateTaskStatusDisplayName < ActiveRecord::Migration
  def self.up
    TaskStatus.enumeration_model_updates_permitted = true    
    
    TaskStatus.find_by_name("waiting").update_attribute(:display_name, "Waiting")
    TaskStatus.find_by_name("will").update_attribute(:display_name, "Will")
    TaskStatus.find_by_name("did").update_attribute(:display_name, "Did")
    TaskStatus.find_by_name("cant").update_attribute(:display_name, "Can't")
    
    TaskStatus.enumeration_model_updates_permitted = false    
  end

  def self.down
  end
end

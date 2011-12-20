class UpdateTaskStatus < ActiveRecord::Migration
  def self.up
    add_column :task_statuses, :display_name, :string
    
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.find_by_name("pending").destroy
    
    TaskStatus.find_by_name("waiting").update_attribute(:display_name, "Waiting")
    TaskStatus.find_by_name("will").update_attribute(:display_name, "Will")
    TaskStatus.find_by_name("did").update_attribute(:display_name, "Did")
    TaskStatus.find_by_name("cant").update_attribute(:display_name, "Can't")
    
    TaskStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.create :name => "pending"
    TaskStatus.enumeration_model_updates_permitted = false
    
    remove_column :task_statuses, :display_name
  end
end

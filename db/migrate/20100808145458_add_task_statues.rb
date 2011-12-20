class AddTaskStatues < ActiveRecord::Migration
  def self.up
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.create :name => "will"
    TaskStatus.create :name => "did"
    TaskStatus.create :name => "cant"
    TaskStatus.enumeration_model_updates_permitted = false
  end

  def self.down
    TaskStatus.enumeration_model_updates_permitted = true    
    TaskStatus.destroy_all
    TaskStatus.enumeration_model_updates_permitted = false
  end
end

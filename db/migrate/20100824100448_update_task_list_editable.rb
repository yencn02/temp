class UpdateTaskListEditable < ActiveRecord::Migration
  def self.up
    TaskList.all.each { |t| t.update_attribute(:editable, false) }
  end

  def self.down    
  end
end

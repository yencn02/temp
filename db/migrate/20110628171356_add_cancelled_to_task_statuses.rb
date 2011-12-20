class AddCancelledToTaskStatuses < ActiveRecord::Migration
  def self.up
    TaskStatus.enumeration_model_updates_permitted = true
    TaskStatus.create(:name => 'cancelled', :created_at => Time.now, :updated_at => Time.now)
  end

  def self.down
    TaskStatus.enumeration_model_updates_permitted = true
    TaskStatus.find_by_name('cancelled').destroy
  end
end

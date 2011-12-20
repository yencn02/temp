class FixTaskListsEditableProperty < ActiveRecord::Migration
  def self.up
    TaskList.all.each do |t|
      if t.title == 'General' or t.title == 'Work' or t.title == 'Family' or t.title == 'Personal' or t.title == 'Friends' then
        t.editable = false
        t.save false
      end
    end
  end

  def self.down
  end
end

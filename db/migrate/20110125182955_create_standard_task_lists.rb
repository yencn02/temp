require 'active_record/fixtures'

class CreateStandardTaskLists < ActiveRecord::Migration
  def self.up
		create_table :standard_task_lists do |t|
			t.string :title
			t.string :icon_name

			t.timestamps
		end
		StandardTaskList.create({:title => "General", :icon_name => "General.png"})
		StandardTaskList.create({:title => "Work", :icon_name => "Work.png"})
		StandardTaskList.create({:title => "Family", :icon_name => "Family.png"})
		StandardTaskList.create({:title => "Personal", :icon_name => "Personal.png"})
		StandardTaskList.create({:title => "Friends", :icon_name => "Friends.png"})
  end

  def self.down
		drop_table :standard_task_lists
  end
end

class FixTaskListsEditable < ActiveRecord::Migration
  def self.up
		tasks = TaskList.find_all_by_title("General")
		tasks.each do |t|
			t.update_attribute(:editable, false)
		end

		tasks = TaskList.find_all_by_title("Work")
		tasks.each do |t|
			t.update_attribute(:editable, false)
		end

		tasks = TaskList.find_all_by_title("Family")
		tasks.each do |t|
			t.update_attribute(:editable, false)
		end

		tasks = TaskList.find_all_by_title("Personal")
		tasks.each do |t|
			t.update_attribute(:editable, false)
		end

		tasks = TaskList.find_all_by_title("Friends")
		tasks.each do |t|
			t.update_attribute(:editable, false)
		end
  end

  def self.down
  end
end

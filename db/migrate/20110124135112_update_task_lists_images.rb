class UpdateTaskListsImages < ActiveRecord::Migration
  def self.up
		tasks = TaskList.find_all_by_icon_name("family")
		tasks.each do |t|
			t.update_attribute(:icon_name, "family.gif")
		end

		tasks = TaskList.find_all_by_icon_name("personal")
		tasks.each do |t|
			t.update_attribute(:icon_name, "personal.gif")
		end

		tasks = TaskList.find_all_by_icon_name("friends")
		tasks.each do |t|
			t.update_attribute(:icon_name, "friends.gif")
		end
  end

  def self.down
		tasks = TaskList.find_all_by_icon_name("family.gif")
		tasks.each do |t|
			t.update_attribute(:icon_name, "family")
		end

		tasks = TaskList.find_all_by_icon_name("personal.gif")
		tasks.each do |t|
			t.update_attribute(:icon_name, "personal")
		end

		tasks = TaskList.find_all_by_icon_name("friends.gif")
		tasks.each do |t|
			t.update_attribute(:icon_name, "friends")
		end
  end
end

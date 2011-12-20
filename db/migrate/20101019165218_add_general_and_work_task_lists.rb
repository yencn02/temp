class AddGeneralAndWorkTaskLists < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      oldest_task_list = user.task_lists.first.created_at

      ["Work", "General"].each_with_index do |title, index|
        unless user.task_lists.find_by_title(title)
          tl = user.task_lists.create(:title => title, :icon_name => "family", :editable => false)
          tl.update_attribute(:created_at, (index + 1).days.ago(oldest_task_list))
        end
      end
    end
  end

  def self.down
  end
end

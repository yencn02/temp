class RemoveInconsistentData < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.from_me.each do |task|
        # remove task if it is assigned to a non-friend        
        unless Friendship.friendship_exists?(user, task.assignee)
          task.destroy
          puts "task #{task.id} destroyed"
        end
      end
      
      user.task_lists_connections.each do |connection|
        # remove task list connection if it is granted to a non-friend
        unless Friendship.friendship_exists?(user, connection.editor)
          connection.destroy
          puts "task list connection #{connection.id} destroyed"
        end
      end
    end
  end

  def self.down
  end
end

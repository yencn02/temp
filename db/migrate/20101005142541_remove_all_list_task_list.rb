class RemoveAllListTaskList < ActiveRecord::Migration
  def self.up
    TaskList.find_all_by_title('All List').each do |tl|
      TaskListConnection.find_all_by_task_list_id(tl.id).each { |tlc| tlc.destroy }
      Task.find_all_by_task_list_id(tl.id).each { |t| t.destroy }
      execute("delete from #{::TaskList.table_name} where id = #{tl.id}")
    end
  end

  def self.down
  end
end

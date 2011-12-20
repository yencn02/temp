class CreateTaskLists < ActiveRecord::Migration
  def self.up
    create_table :task_lists do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :task_lists
  end
end

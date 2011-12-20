class RemoveSpamFromTask < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :spam_state
  end

  def self.down
  end
end

class AddSpamStateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :spam_state, :string, :default => Badr::Acts::Spammable::Constants::NORMAL
    Task.update_all(['spam_state = ?', Badr::Acts::Spammable::Constants::NORMAL]);
  end

  def self.down
    remove_column :tasks, :spam_state
  end
  
end

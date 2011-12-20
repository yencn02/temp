class FixSpammableDefaultValue < ActiveRecord::Migration
  def self.up
    remove_column :tasks, :spam_state
    add_column :tasks, :spam_state, :string, :default => Badr::Acts::Spammable::Constants::NORMAL
    Task.update_all(['spam_state = ?', Badr::Acts::Spammable::Constants::NORMAL])
  end

  def self.down
  end
end

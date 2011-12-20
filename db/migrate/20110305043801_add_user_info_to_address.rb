class AddUserInfoToAddress < ActiveRecord::Migration
  def self.up
    add_column :addresses, :user_info_id, :integer
  end

  def self.down
  end
end

class DropRelativesFromUserInfo < ActiveRecord::Migration
  def self.up
    remove_column :user_infos, :relatives
  end

  def self.down
    add_column :user_infos, :relatives , :text
  end
end

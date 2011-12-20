class FillUserInfos < ActiveRecord::Migration
  def self.up
    users = User.all
    users.each do |u|
      UserInfo.new(:user_id => u.id).save
    end
  end

  def self.down
  end
end

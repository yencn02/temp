class AddUserInfo < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.column :first_name, :string, :limit => 30, :null => false
      t.column :last_name, :string, :limit => 30, :null => false
    end
  end

  def self.down
    change_table(:users) do |t|
      t.remove :first_name
      t.remove :last_name
    end    
  end
end

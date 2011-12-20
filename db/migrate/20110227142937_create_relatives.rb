class CreateRelatives < ActiveRecord::Migration
  def self.up
    create_table :relatives_relationships do |t|
      t.integer :user_info_id
      t.integer :relative_info_id
      
      t.timestamps 
    end
  end

  def self.down
    drop_table :relatives_relationships
  end
end

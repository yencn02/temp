class CreateSpamReports < ActiveRecord::Migration
  def self.up
    create_table :spam_reports do |t|
      t.integer :user_id
      t.integer :reportee_id
      t.boolean :spam
      
      t.timestamps
    end
  end

  def self.down
    drop_table :spam_reports
  end
  
end

class CreateWaitingPages < ActiveRecord::Migration
  def self.up
    create_table :waiting_pages do |t|
      t.string :email, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :waiting_pages
  end
end

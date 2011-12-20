class Address < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.string :country
      t.string :state
      t.string :city
      t.string :street1
      t.string :street2
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end

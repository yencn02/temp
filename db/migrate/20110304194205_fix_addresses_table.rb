class FixAddressesTable < ActiveRecord::Migration
  def self.up
    drop_table :addresses
    create_table :addresses do |t|
      t.integer :country_id
      t.integer :city_id
      t.string :street1
      t.string :street2
      
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end

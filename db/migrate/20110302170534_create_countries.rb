class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :iso2
      t.string :name
    end
  end

  def self.down
    drop_table :countries
  end
end

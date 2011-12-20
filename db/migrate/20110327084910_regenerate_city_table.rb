class RegenerateCityTable < ActiveRecord::Migration
  def self.up
    drop_table :cities
    create_table :cities do |t|
      t.integer :country_id
      t.string :name
      t.text :aliases
      t.decimal :latitude, :precision => 10, :scale => 7
      t.decimal :longitude, :precision => 10, :scale => 7
    end
  end

  def self.down
    drop_table :cities
  end
end
